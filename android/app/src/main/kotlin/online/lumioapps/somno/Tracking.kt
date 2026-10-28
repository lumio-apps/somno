package online.lumioapps.somno

import android.content.Context
import android.content.Intent
import android.os.Build

object Tracking {
    fun start(context: Context) {
        if (!EventStore.shouldRunNow(context)) {
            return
        }
        try {
            val intent = Intent(context, SleepService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        } catch (e: Exception) {
            // Android refused to start it right now; the app retries when opened.
        }
    }

    fun stop(context: Context) {
        context.stopService(Intent(context, SleepService::class.java))
    }
}
