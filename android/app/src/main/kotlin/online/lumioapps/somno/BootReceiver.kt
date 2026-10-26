package online.lumioapps.somno

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Restarts tracking after the phone boots or the app is updated. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!EventStore.isEnabled(context)) {
            return
        }
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            EventStore.add(context, "boot")
        }
        Tracking.start(context)
    }
}
