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
                    if (EventStore.isEnabled(this) && !SleepService.running) {
                        Tracking.start(this)
                    }
                    result.success(null)
                }
                "drainEvents" -> result.success(EventStore.drain(this))
                "isBatteryUnrestricted" -> result.success(isBatteryUnrestricted())
                "openBatterySettings" -> {
                    openBatterySettings()
                    result.success(null)
                }
                "appVersion" -> result.success(appVersion())
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

    private fun appVersion(): String {
        return try {
            packageManager.getPackageInfo(packageName, 0).versionName ?: ""
        } catch (e: Exception) {
            ""
        }
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
