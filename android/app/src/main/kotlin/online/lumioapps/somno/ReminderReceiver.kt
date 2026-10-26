package online.lumioapps.somno

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Fires at bedtime, shows the reminder and sets tomorrow's alarm. */
class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!Reminder.isEnabled(context)) {
            return
        }
        Reminder.show(context)
        Reminder.schedule(context)
    }
}
