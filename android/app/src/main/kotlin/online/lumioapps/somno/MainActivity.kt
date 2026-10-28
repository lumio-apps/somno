package online.lumioapps.somno

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "online.lumioapps.somno/native"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTracking" -> {
                    EventStore.setEnabled(this, true)
                    if (!SleepService.running) {
                        Tracking.start(this)
                    }
                    result.success(null)
                }
                "stopTracking" -> {
                    EventStore.setEnabled(this, false)
                    Tracking.stop(this)
                    EventStore.clear(this)
                    result.success(null)
                }
                "ensureTracking" -> {
                    // The app is open, so the phone is unlocked right now.
                    EventStore.setPendingOff(this, false)
                    if (EventStore.shouldRunNow(this)) {
                        if (!SleepService.running) {
                            Tracking.start(this)
                        }
                    } else if (SleepService.running) {
                        Tracking.stop(this)
                    }
                    result.success(null)
                }
                "setWindow" -> {
                    EventStore.setWindow(
                        this,
                        call.argument<Int>("mode") ?: 2,
                        call.argument<Int>("start") ?: 0,
                        call.argument<Int>("end") ?: 0
                    )
                    result.success(null)
                }
                "drainEvents" -> result.success(EventStore.drain(this))
                "isBatteryUnrestricted" -> result.success(isBatteryUnrestricted())
                "openBatterySettings" -> {
                    openBatterySettings()
                    result.success(null)
                }
                "setReminder" -> {
                    Reminder.configure(
                        this,
                        call.argument<Boolean>("enabled") ?: false,
                        call.argument<Int>("minute") ?: (22 * 60 + 30),
                        call.argument<String>("locale") ?: ""
                    )
                    result.success(null)
                }
                "updatesDir" -> {
                    val dir = java.io.File(cacheDir, "updates")
                    dir.mkdirs()
                    result.success(dir.absolutePath)
                }
                "installApk" -> result.success(installApk(call.argument<String>("path")))
                "hasUsageAccess" -> result.success(ScreenHistory.hasAccess(this))
                "openUsageAccess" -> {
                    openUsageAccess()
                    result.success(null)
                }
                "screenHistory" -> {
                    val from = call.argument<Number>("from")?.toLong() ?: 0L
                    val to = call.argument<Number>("to")?.toLong() ?: 0L
                    result.success(ScreenHistory.read(this, from, to))
                }
                "trackingStatus" -> result.success(trackingStatus())
                "openAutostart" -> result.success(openAutostart())
                "appVersion" -> result.success(appVersion())
                "openWellbeing" -> result.success(openWellbeing())
                "openUrl" -> {
                    result.success(openUrl(call.argument<String>("url")))
                }
                "requestNotifications" -> {
                    requestNotifications()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isBatteryUnrestricted(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true
        }
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun openBatterySettings() {
        try {
            startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
        } catch (e: Exception) {
            try {
                startActivity(
                    Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.parse("package:$packageName")
                    )
                )
            } catch (e2: Exception) {
                // No settings screen available.
            }
        }
    }

    private fun openUsageAccess() {
        try {
            startActivity(
                Intent(
                    Settings.ACTION_USAGE_ACCESS_SETTINGS,
                    Uri.parse("package:$packageName")
                )
            )
        } catch (e: Exception) {
            try {
                startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
            } catch (e2: Exception) {
                // No such screen on this phone.
            }
        }
    }

    private fun trackingStatus(): HashMap<String, Any> {
        val times = EventStore.lastTimes(this)
        val map = HashMap<String, Any>()
        map["running"] = SleepService.running
        map["manufacturer"] = Build.MANUFACTURER ?: ""
        map["model"] = Build.MODEL ?: ""
        map["sdk"] = Build.VERSION.SDK_INT
        map["lastOff"] = times[0]
        map["lastUnlock"] = times[1]
        map["lastStart"] = times[2]
        return map
    }

    /** Opens the autostart screen of Xiaomi, Oppo, Vivo or Huawei phones. */
    private fun openAutostart(): Boolean {
        val screens = listOf(
            "com.miui.securitycenter" to
                "com.miui.permcenter.autostart.AutoStartManagementActivity",
            "com.coloros.safecenter" to
                "com.coloros.safecenter.permission.startup.StartupAppListActivity",
            "com.vivo.permissionmanager" to
                "com.vivo.permissionmanager.activity.BgStartUpManagerActivity",
            "com.huawei.systemmanager" to
                "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
        )
        for ((pkg, cls) in screens) {
            try {
                startActivity(Intent().setClassName(pkg, cls))
                return true
            } catch (e: Exception) {
                // Not this brand, try the next one.
            }
        }
        try {
            startActivity(
                Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.parse("package:$packageName")
                )
            )
        } catch (e: Exception) {
            // No settings screen available.
        }
        return false
    }

    private fun appVersion(): String {
        return try {
            packageManager.getPackageInfo(packageName, 0).versionName ?: ""
        } catch (e: Exception) {
            ""
        }
    }

    /** Returns "ok", "permission" (user must allow installs) or "error". */
    private fun installApk(path: String?): String {
        if (path == null) {
            return "error"
        }
        val file = java.io.File(path)
        if (!file.exists()) {
            return "error"
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                !packageManager.canRequestPackageInstalls()
            ) {
                startActivity(
                    Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:$packageName")
                    )
                )
                return "permission"
            }
            val uri = androidx.core.content.FileProvider.getUriForFile(
                this,
                "$packageName.fileprovider",
                file
            )
            val intent = Intent(Intent.ACTION_VIEW)
                .setDataAndType(uri, "application/vnd.android.package-archive")
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            startActivity(intent)
            return "ok"
        } catch (e: Exception) {
            return "error"
        }
    }

    private fun openWellbeing(): Boolean {
        val explicit = Intent().setClassName(
            "com.google.android.apps.wellbeing",
            "com.google.android.apps.wellbeing.settings.TopLevelSettingsActivity"
        )
        try {
            startActivity(explicit)
            return true
        } catch (e: Exception) {
            // Not a Google Wellbeing phone, try the launcher of known apps.
        }
        val packages = listOf(
            "com.google.android.apps.wellbeing",
            "com.samsung.android.forest"
        )
        for (pkg in packages) {
            try {
                val launch = packageManager.getLaunchIntentForPackage(pkg)
                if (launch != null) {
                    startActivity(launch)
                    return true
                }
            } catch (e: Exception) {
                // Try the next one.
            }
        }
        try {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        } catch (e: Exception) {
            // No settings screen available.
        }
        return false
    }

    private fun openUrl(url: String?): Boolean {
        if (url == null || !url.startsWith("https://")) {
            return false
        }
        return try {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun requestNotifications() {
        if (Build.VERSION.SDK_INT >= 33 &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1001)
        }
    }
}
