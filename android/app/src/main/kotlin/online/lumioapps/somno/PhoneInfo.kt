package online.lumioapps.somno

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.display.DisplayManager
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.PowerManager
import android.os.StatFs
import android.os.SystemClock
import android.view.Display

/**
 * Facts about this phone, read live from Android when the Phone tab asks.
 * Nothing is stored, logged or sent anywhere.
 */
object PhoneInfo {

    fun snapshot(context: Context): Map<String, Any?> {
        val out = HashMap<String, Any?>()
        out["battery"] = battery(context)
        out["device"] = device(context)
        return out
    }

    private fun battery(context: Context): Map<String, Any?> {
        val b = HashMap<String, Any?>()
        val i = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        if (i == null) {
            b["level"] = -1
            return b
        }
        val level = i.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = i.getIntExtra(BatteryManager.EXTRA_SCALE, 100)
        b["level"] = if (level >= 0 && scale > 0) level * 100 / scale else -1
        b["status"] = i.getIntExtra(BatteryManager.EXTRA_STATUS, 1)
        b["plugged"] = i.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0)
        b["health"] = i.getIntExtra(BatteryManager.EXTRA_HEALTH, 1)
        // Tenths of a degree Celsius, and millivolts.
        b["tempTenths"] = i.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE)
        b["millivolts"] = i.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
        b["technology"] = i.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY) ?: ""
        // Only newer Android versions (14 and up) report this, and only some phones.
        b["cycles"] = i.getIntExtra("android.os.extra.CYCLE_COUNT", -1)
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        b["saver"] = pm.isPowerSaveMode
        return b
    }

    private fun device(context: Context): Map<String, Any?> {
        val d = HashMap<String, Any?>()
        d["manufacturer"] = Build.MANUFACTURER ?: ""
        d["model"] = Build.MODEL ?: ""
        d["release"] = Build.VERSION.RELEASE ?: ""
        d["sdk"] = Build.VERSION.SDK_INT
        d["patch"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Build.VERSION.SECURITY_PATCH ?: ""
        } else {
            ""
        }
        d["abi"] = Build.SUPPORTED_ABIS.firstOrNull() ?: ""
        d["cores"] = Runtime.getRuntime().availableProcessors()
        d["uptimeMs"] = SystemClock.elapsedRealtime()

        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mem = ActivityManager.MemoryInfo()
        am.getMemoryInfo(mem)
        d["ramTotal"] = mem.totalMem
        d["ramFree"] = mem.availMem

        try {
            val stat = StatFs(Environment.getDataDirectory().path)
            d["storageTotal"] = stat.totalBytes
            d["storageFree"] = stat.availableBytes
        } catch (e: Exception) {
            d["storageTotal"] = 0L
            d["storageFree"] = 0L
        }

        val metrics = context.resources.displayMetrics
        d["width"] = metrics.widthPixels
        d["height"] = metrics.heightPixels
        d["dpi"] = metrics.densityDpi
        try {
            val dm = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
            d["hz"] = dm.getDisplay(Display.DEFAULT_DISPLAY)?.refreshRate ?: 0f
        } catch (e: Exception) {
            d["hz"] = 0f
        }
        return d
    }

    /** Opens Android's own battery usage page. Returns false if only Settings opened. */
    fun openBatteryUsage(context: Context): Boolean {
        val intents = listOf(
            Intent(Intent.ACTION_POWER_USAGE_SUMMARY),
            Intent(android.provider.Settings.ACTION_BATTERY_SAVER_SETTINGS),
            Intent(android.provider.Settings.ACTION_SETTINGS)
        )
        for ((index, intent) in intents.withIndex()) {
            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                return index == 0
            } catch (e: Exception) {
                // Try the next one.
            }
        }
        return false
    }
}
