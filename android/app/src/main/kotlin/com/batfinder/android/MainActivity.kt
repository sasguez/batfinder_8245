package com.batfinder.android

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentResolver
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterFragmentActivity() {

    private val SCREEN_CHANNEL = "com.batfinder.android/screen_events"
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createAlertNotificationChannel()
    }

    private fun createAlertNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val soundUri = Uri.parse(
            "${ContentResolver.SCHEME_ANDROID_RESOURCE}://${packageName}/raw/batfinder_alert"
        )
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val channel = NotificationChannel(
            "batfinder_alerts",
            "Alertas BatFinder",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Alertas de seguridad comunitaria"
            setSound(soundUri, audioAttributes)
            enableLights(true)
            enableVibration(true)
        }
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // EventChannel que usa PowerButtonDetectorService.dart para recibir eventos.
        // Los eventos ahora los genera ScreenListenerService (no un BroadcastReceiver
        // propio de MainActivity), eliminando así la duplicación cuando la app está activa.
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    ScreenListenerService.screenEventListener = { eventType ->
                        runOnUiThread { eventSink?.success(eventType) }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    ScreenListenerService.screenEventListener = null
                    eventSink = null
                }
            })
    }

    override fun onStart() {
        super.onStart()
        startScreenService()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // La bandera batfinder_panic_pending ya fue escrita por ScreenListenerService;
        // Flutter la leerá en el próximo resume/hot-restart automáticamente.
    }

    override fun onDestroy() {
        ScreenListenerService.screenEventListener = null
        super.onDestroy()
    }

    private fun startScreenService() {
        val svc = Intent(this, ScreenListenerService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(svc)
        } else {
            startService(svc)
        }
    }
}
