package online.lumioapps.somno

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.Build
import java.util.Calendar
import java.util.Locale

/**
 * One notification a day at the time the user picked. It uses the alarm
 * clock of Android only; nothing is sent anywhere.
 */
object Reminder {
    private const val PREFS = "somno_reminder"
    private const val CHANNEL_ID = "somno_reminder"
    private const val NOTIFICATION_ID = 1002
    private const val REQUEST_CODE = 2001

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun configure(
        context: Context,
        enabled: Boolean,
        minuteOfDay: Int,
        localeCode: String
    ) {
        prefs(context).edit()
            .putBoolean("enabled", enabled)
            .putInt("minute", minuteOfDay)
            .putString("locale", localeCode)
            .apply()
        schedule(context)
    }

    fun isEnabled(context: Context): Boolean =
        prefs(context).getBoolean("enabled", false)

    /** Sets the next alarm, or removes it when the reminder is off. */
    fun schedule(context: Context) {
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pending = pending(context)
        if (!isEnabled(context)) {
            alarms.cancel(pending)
            return
        }
        val at = nextTriggerMs(prefs(context).getInt("minute", 22 * 60 + 30))
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pending)
            } else {
                alarms.set(AlarmManager.RTC_WAKEUP, at, pending)
            }
        } catch (e: Exception) {
            // Android refused the alarm; it is set again when the app opens.
        }
    }

    private fun pending(context: Context): PendingIntent {
        return PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            Intent(context, ReminderReceiver::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    fun nextTriggerMs(minuteOfDay: Int, now: Long = System.currentTimeMillis()): Long {
        val cal = Calendar.getInstance()
        cal.timeInMillis = now
        cal.set(Calendar.HOUR_OF_DAY, minuteOfDay / 60)
        cal.set(Calendar.MINUTE, minuteOfDay % 60)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        if (cal.timeInMillis <= now) {
            cal.add(Calendar.DAY_OF_YEAR, 1)
        }
        return cal.timeInMillis
    }

    /** Shows the reminder in the language chosen inside the app. */
    fun show(context: Context) {
        val code = prefs(context).getString("locale", "") ?: ""
        var texts = context
        if (code.isNotEmpty()) {
            val config = Configuration(context.resources.configuration)
            config.setLocale(Locale(code))
            texts = context.createConfigurationContext(config)
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager
        if (!manager.areNotificationsEnabled()) {
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    texts.getString(R.string.reminder_channel),
                    NotificationManager.IMPORTANCE_DEFAULT
                )
            )
        }
        val openApp = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            Notification.Builder(context)
        }
        val notification = builder
            .setSmallIcon(R.drawable.ic_stat_somno)
            .setContentTitle(texts.getString(R.string.reminder_title))
            .setContentText(texts.getString(R.string.reminder_text))
            .setContentIntent(openApp)
            .setAutoCancel(true)
            .build()
        manager.notify(NOTIFICATION_ID, notification)
    }
}
