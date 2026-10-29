package online.lumioapps.somno

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import android.os.Process
import org.json.JSONArray
import org.json.JSONObject

/**
 * Reads when the screen turned off and when the phone was unlocked from
 * Android's own usage history. This works even when Android stopped the
 * tracking service during the night. Sleep detection reads only these two
 * kinds of event. App screen time is read separately in AppUsage.kt for the
 * Phone tab. Nothing leaves the phone.
 */
object ScreenHistory {
    // UsageEvents.Event.SCREEN_NON_INTERACTIVE and KEYGUARD_HIDDEN (API 28).
    private const val SCREEN_NON_INTERACTIVE = 16
    private const val KEYGUARD_HIDDEN = 18

    fun hasAccess(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            return false
        }
        return try {
            val ops = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ops.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName
                )
            } else {
                @Suppress("DEPRECATION")
                ops.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }

    /** JSON like the service queue: [{"t": millis, "e": "off" | "unlock"}]. */
    fun read(context: Context, fromMs: Long, toMs: Long): String {
        val out = JSONArray()
        if (!hasAccess(context)) {
            return out.toString()
        }
        try {
            val manager =
                context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val events = manager.queryEvents(fromMs, toMs)
            val event = UsageEvents.Event()
            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                when (event.eventType) {
                    SCREEN_NON_INTERACTIVE ->
                        out.put(JSONObject().put("t", event.timeStamp).put("e", "off"))
                    KEYGUARD_HIDDEN ->
                        out.put(JSONObject().put("t", event.timeStamp).put("e", "unlock"))
                }
            }
        } catch (e: Exception) {
            // Android refused; the service events are used instead.
        }
        return out.toString()
    }
}
