package com.batfinder.android

import android.app.*
import android.content.*
import android.os.*
import androidx.core.app.NotificationCompat

/**
 * Servicio en primer plano que escucha eventos de pantalla apagada/encendida.
 *
 * Mientras la app está activa: reenvía eventos a MainActivity via [screenEventListener]
 * para que Flutter los cuente con su propia lógica (PowerButtonDetectorService.dart).
 *
 * Mientras la app está cerrada: cuenta los toques aquí mismo y, al detectar el
 * patrón, escribe la bandera batfinder_panic_pending en SharedPreferences y muestra
 * una notificación de alta prioridad. Al abrirla, Flutter lee la bandera y navega
 * directamente a EmergencyPanicMode.
 */
class ScreenListenerService : Service() {

    companion object {
        const val CHANNEL_ID      = "batfinder_protection"
        const val NOTIFICATION_ID = 1001

        private const val PREFS_FLUTTER      = "FlutterSharedPreferences"
        private const val KEY_REQUIRED_TAPS  = "flutter.power_button_required_taps"
        private const val KEY_PANIC_PENDING  = "flutter.batfinder_panic_pending"
        private const val DEFAULT_REQUIRED   = 3
        private const val TAP_WINDOW_MS      = 5_000L

        /**
         * MainActivity registra aquí un callback para recibir eventos de pantalla
         * mientras la app está en primer plano. Cuando es null, el servicio maneja
         * la detección por sí mismo.
         */
        var screenEventListener: ((String) -> Unit)? = null
    }

    private var screenReceiver: BroadcastReceiver? = null
    private var bgTapCount = 0
    private var bgPending  = false
    private val handler    = Handler(Looper.getMainLooper())
    private val resetBg    = Runnable { bgTapCount = 0 }

    // ── Ciclo de vida ──────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildIdleNotification())
        registerScreenReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int =
        START_STICKY   // se reinicia solo si el SO lo termina

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        unregisterScreenReceiver()
        super.onDestroy()
    }

    // ── Recepción de eventos de pantalla ───────────────────────────────────────

    private fun registerScreenReceiver() {
        screenReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val eventType = when (intent?.action) {
                    Intent.ACTION_SCREEN_OFF -> "screen_off"
                    Intent.ACTION_SCREEN_ON  -> "screen_on"
                    else -> return
                }

                val listener = screenEventListener
                if (listener != null) {
                    // App activa → delegar a Flutter a través del EventChannel
                    listener(eventType)
                } else {
                    // App cerrada o en segundo plano → manejar aquí
                    handleBackgroundEvent(eventType)
                }
            }
        }
        registerReceiver(
            screenReceiver,
            IntentFilter().apply {
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(Intent.ACTION_SCREEN_ON)
            }
        )
    }

    private fun handleBackgroundEvent(eventType: String) {
        val required = getRequiredTaps()

        if (eventType == "screen_off") {
            bgTapCount++
            handler.removeCallbacks(resetBg)

            if (bgTapCount >= required) {
                bgTapCount = 0
                bgPending  = true
                // Espera screen_on para disparar (pantalla activa antes de notificar)
            } else {
                handler.postDelayed(resetBg, TAP_WINDOW_MS)
            }
        }

        if (eventType == "screen_on" && bgPending) {
            bgPending = false
            triggerPanicFromBackground()
        }
    }

    // ── Activación de pánico desde segundo plano ───────────────────────────────

    private fun triggerPanicFromBackground() {
        // 1. Bandera que Flutter lee al iniciar
        getSharedPreferences(PREFS_FLUTTER, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_PANIC_PENDING, true)
            .apply()

        // 2. Notificación de alta prioridad visible en pantalla de bloqueo
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pi = PendingIntent.getActivity(
            this, 99, launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notif = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🚨 MODO PÁNICO ACTIVADO")
            .setContentText("BatFinder detectó la señal SOS. Toca para activar alertas.")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentIntent(pi)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()

        getSystemService(NotificationManager::class.java)
            .notify(NOTIFICATION_ID + 1, notif)
    }

    // ── Utilidades ─────────────────────────────────────────────────────────────

    private fun getRequiredTaps(): Int {
        // Flutter shared_preferences guarda con prefijo "flutter." y los int como Long
        val prefs = getSharedPreferences(PREFS_FLUTTER, Context.MODE_PRIVATE)
        return prefs.getLong(KEY_REQUIRED_TAPS, DEFAULT_REQUIRED.toLong()).toInt()
            .coerceIn(1, 10)
    }

    private fun unregisterScreenReceiver() {
        screenReceiver?.let {
            try { unregisterReceiver(it) } catch (_: Exception) {}
        }
        screenReceiver = null
    }

    // ── Notificación persistente (modo reposo) ─────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "BatFinder Protección",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Monitoreo SOS activo en segundo plano"
                    setShowBadge(false)
                }
            )
        }
    }

    private fun buildIdleNotification(): Notification {
        val pi = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("BatFinder activo")
            .setContentText("Protección SOS habilitada")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentIntent(pi)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}
