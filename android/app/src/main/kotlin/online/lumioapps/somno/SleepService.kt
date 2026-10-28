package online.lumioapps.somno

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/**
 * Listens for screen off and unlock events and saves them to [EventStore].
 * It never reads anything else and never uses the network.
 */
class SleepService : Service() {

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_SCREEN_OFF -> {
                    EventStore.add(context, "off")
                    if (!EventStore.hasPendingOff(context)) {
                        if (EventStore.inWindowNow(context)) {
                            EventStore.setPendingOff(context, true)
                        } else {
                            // A sleep starting outside the window does not count.
                            this@SleepService.stopSelf()
                        }
                    }
                }
                Intent.ACTION_USER_PRESENT -> {
                    EventStore.add(context, "unlock")
                    EventStore.setPendingOff(context, false)
                    if (!EventStore.inWindowNow(context)) {
                        // The window is over and the sleep has ended: stop.
                        this@SleepService.stopSelf()
                    }
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        running = true
        showNotification()
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!EventStore.shouldRunNow(this)) {
            stopSelf()
            return START_NOT_STICKY
        }
        // intent == null means Android restarted the service after killing it.
        EventStore.add(this, if (intent == null) "restart" else "start")
        return START_STICKY
    }

    override fun onDestroy() {
        running = false
        try {
            unregisterReceiver(receiver)
        } catch (e: Exception) {
            // Already unregistered.
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun showNotification() {
        val channelId = "somno_tracking"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            val channel = NotificationChannel(
                channelId,
                getString(R.string.channel_name),
                NotificationManager.IMPORTANCE_MIN
            )
            manager.createNotificationChannel(channel)
        }
        val openApp = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
        } else {
            Notification.Builder(this)
        }
        val notification = builder
            .setSmallIcon(R.drawable.ic_stat_somno)
            .setContentTitle(getString(R.string.notif_title))
            .setContentText(getString(R.string.notif_text))
            .setContentIntent(openApp)
            .setOngoing(true)
            .build()
        try {
            if (Build.VERSION.SDK_INT >= 34) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            // Android did not allow a foreground start right now.
            stopSelf()
        }
    }

    companion object {
        private const val NOTIFICATION_ID = 1001

        @Volatile
        var running = false
    }
}
