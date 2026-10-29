package online.lumioapps.somno

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import java.io.ByteArrayOutputStream

/**
 * How long each app was on screen, read from Android's own usage history
 * when the Phone tab asks. Needs Usage access. The result is shown on the
 * phone and is never saved, logged or sent anywhere.
 */
object AppUsage {
    // UsageEvents.Event constants (the first two are named differently on newer Android).
    private const val RESUMED = 1
    private const val PAUSED = 2
    private const val SCREEN_NON_INTERACTIVE = 16
    private const val DEVICE_SHUTDOWN = 26

    // An app that was already open when the range began, or whose start we never saw,
    // is counted for at most this long, so one lost event cannot add hours.
    private const val ORPHAN_CAP_MS = 3L * 60 * 60 * 1000

    /** Apps with time in [from, to), most used first. Empty without Usage access. */
    fun read(context: Context, from: Long, to: Long): List<Map<String, Any>> {
        if (to <= from || !ScreenHistory.hasAccess(context)) {
            return emptyList()
        }
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(from, to) ?: return emptyList()

        val depth = HashMap<String, Int>()
        val started = HashMap<String, Long>()
        val totals = HashMap<String, Long>()

        fun add(pkg: String, ms: Long) {
            if (ms > 0) {
                totals[pkg] = (totals[pkg] ?: 0L) + ms
            }
        }

        fun closeAll(at: Long) {
            for ((pkg, d) in depth) {
                if (d > 0) {
                    add(pkg, at - (started[pkg] ?: at))
                }
            }
            depth.clear()
            started.clear()
        }

        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            val pkg = e.packageName ?: continue
            when (e.eventType) {
                RESUMED -> {
                    val d = depth[pkg] ?: 0
                    if (d == 0) {
                        started[pkg] = e.timeStamp
                    }
                    depth[pkg] = d + 1
                }
                PAUSED -> {
                    val d = depth[pkg] ?: 0
                    if (d > 1) {
                        depth[pkg] = d - 1
                    } else if (d == 1) {
                        depth[pkg] = 0
                        add(pkg, e.timeStamp - (started[pkg] ?: e.timeStamp))
                    } else {
                        // Opened before this range began.
                        add(pkg, minOf(e.timeStamp - from, ORPHAN_CAP_MS))
                    }
                }
                SCREEN_NON_INTERACTIVE, DEVICE_SHUTDOWN -> closeAll(e.timeStamp)
            }
        }
        // Still open at the end of the range.
        for ((pkg, d) in depth) {
            if (d > 0) {
                add(pkg, to - (started[pkg] ?: to))
            }
        }

        val pm = context.packageManager
        val home = homePackage(pm)
        val out = ArrayList<Map<String, Any>>()
        for ((pkg, ms) in totals) {
            if (ms < 1000 || pkg == home) {
                continue
            }
            // Only apps with a launcher icon, so system helpers are left out.
            if (pm.getLaunchIntentForPackage(pkg) == null) {
                continue
            }
            val label = try {
                pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
            } catch (ex: Exception) {
                pkg
            }
            out.add(mapOf("package" to pkg, "label" to label, "ms" to ms))
        }
        out.sortByDescending { it["ms"] as Long }
        return out
    }

    private fun homePackage(pm: PackageManager): String? {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)?.activityInfo?.packageName
        } catch (ex: Exception) {
            null
        }
    }

    /** The app's launcher icon as a small PNG, or null if it cannot be drawn. */
    fun icon(context: Context, pkg: String): ByteArray? {
        return try {
            val drawable = context.packageManager.getApplicationIcon(pkg)
            val size = 96
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, size, size)
            drawable.draw(canvas)
            val out = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            out.toByteArray()
        } catch (ex: Exception) {
            null
        }
    }
}
