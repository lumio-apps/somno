package online.lumioapps.somno

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

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
        p.edit().putString(KEY_QUEUE, queue.toString()).commit()
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

    fun setEnabled(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(KEY_ENABLED, enabled).commit()
    }

    fun isEnabled(context: Context): Boolean =
        prefs(context).getBoolean(KEY_ENABLED, false)
}
