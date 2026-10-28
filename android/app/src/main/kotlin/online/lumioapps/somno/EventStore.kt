package online.lumioapps.somno

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

/**
 * Tiny on-device queue of raw screen events. The Flutter side reads it
 * ("drain") when the app opens and turns it into sleep sessions.
 */
object EventStore {
    private const val PREFS = "somno_native"
    private const val KEY_QUEUE = "queue"
    private const val KEY_ENABLED = "tracking_enabled"
    private const val MAX_EVENTS = 2000

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    @Synchronized
    fun add(context: Context, type: String) {
        val p = prefs(context)
        val queue = try {
            JSONArray(p.getString(KEY_QUEUE, "[]"))
        } catch (e: Exception) {
            JSONArray()
        }
        queue.put(JSONObject().put("t", System.currentTimeMillis()).put("e", type))
        while (queue.length() > MAX_EVENTS) {
            queue.remove(0)
        }
        val now = System.currentTimeMillis()
        val lastKey = when (type) {
            "off" -> "last_off"
            "unlock" -> "last_unlock"
            else -> "last_start"
        }
        p.edit()
            .putString(KEY_QUEUE, queue.toString())
            .putLong(lastKey, now)
            .commit()
    }

    /** Last time the service saw a screen-off, an unlock and a start. */
    fun lastTimes(context: Context): LongArray {
        val p = prefs(context)
        return longArrayOf(
            p.getLong("last_off", 0L),
            p.getLong("last_unlock", 0L),
            p.getLong("last_start", 0L)
        )
    }

    @Synchronized
    fun drain(context: Context): String {
        val p = prefs(context)
        val data = p.getString(KEY_QUEUE, "[]") ?: "[]"
        p.edit().putString(KEY_QUEUE, "[]").commit()
        return data
    }

    @Synchronized
    fun clear(context: Context) {
        prefs(context).edit().putString(KEY_QUEUE, "[]").commit()
    }

    /** The tracking window: mode 0 night, 1 day, 2 any time; minutes after midnight. */
    fun setWindow(context: Context, mode: Int, start: Int, end: Int) {
        prefs(context).edit()
            .putInt("win_mode", mode)
            .putInt("win_start", start)
            .putInt("win_end", end)
            .commit()
    }

    fun inWindowNow(context: Context): Boolean {
        val p = prefs(context)
        if (p.getInt("win_mode", 2) == 2) {
            return true
        }
        val start = p.getInt("win_start", 0)
        val end = p.getInt("win_end", 0)
        if (start == end) {
            return true
        }
        val cal = Calendar.getInstance()
        val minute = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
        return if (start < end) {
            minute >= start && minute < end
        } else {
            minute >= start || minute < end
        }
    }

    /** True from a screen-off inside the window until the next unlock. */
    fun hasPendingOff(context: Context): Boolean =
        prefs(context).getBoolean("pending_off", false)

    fun setPendingOff(context: Context, pending: Boolean) {
        prefs(context).edit().putBoolean("pending_off", pending).commit()
    }

    /**
     * The background tracker is needed only when tracking is on, Usage access
     * is not available, and we are inside the sleep window or waiting for the
     * unlock that ends a sleep.
     */
    fun shouldRunNow(context: Context): Boolean {
        if (!isEnabled(context) || ScreenHistory.hasAccess(context)) {
            return false
        }
        return inWindowNow(context) || hasPendingOff(context)
    }

    fun setEnabled(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(KEY_ENABLED, enabled).commit()
    }

    fun isEnabled(context: Context): Boolean =
        prefs(context).getBoolean(KEY_ENABLED, false)
}
