import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import './firebase_options.dart';
import './services/sound_service.dart';
import './services/supabase_service.dart';
import './services/vibration_service.dart';

// Clave global para navegación desde handlers FCM en background
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseService.initialize();
  } catch (e) {
    if (kDebugMode) print('❌ Supabase init error: $e');
  }

  // Verifica si ScreenListenerService activó un pánico mientras la app estaba cerrada
  final prefs = await SharedPreferences.getInstance();
  final panicPending = prefs.getBool('batfinder_panic_pending') ?? false;
  if (panicPending) {
    await prefs.remove('batfinder_panic_pending');
    if (kDebugMode) print('🚨 main: panic_pending detectado — navegando a EmergencyPanicMode');
  }

  // Solo navega directamente a pánico si el usuario tiene sesión activa
  final bool goToPanic = panicPending && SupabaseService.currentUser != null;

  await _initFirebase();

  runApp(MyApp(initialRoute: goToPanic ? AppRoutes.emergencyPanicMode : AppRoutes.splash));
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMessaging.instance.requestPermission();

    // Registrar token cada vez que haya sesión activa: inicio de sesión, restauración, o login nuevo
    SupabaseService.authStateChanges.listen((state) async {
      if (state.session?.user == null) return;
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) await SupabaseService.registerFCMToken(token);
      } catch (e) {
        if (kDebugMode) print('⚠️ FCM token on auth change: $e');
      }
    });
    // Actualizar token en Supabase si FCM lo rota (siempre activo)
    FirebaseMessaging.instance.onTokenRefresh.listen(SupabaseService.registerFCMToken);

    FirebaseMessaging.onMessage.listen((message) async {
      await SoundService().playAlertSound();
      await VibrationService().vibrateAlert();
      if (message.data['type'] == 'PANIC_ALERT') {
        // Obtener contexto después del gap asíncrono para evitar uso obsoleto
        final ctx = navigatorKey.currentContext;
        if (ctx == null || !ctx.mounted) return;
        final theme = Theme.of(ctx);
        showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            title: Row(children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text('Alerta de pánico',
                  style: TextStyle(color: theme.colorScheme.error)),
            ]),
            content: Text(
              message.notification?.body ?? 'Un contacto necesita ayuda urgente',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Ignorar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  navigatorKey.currentState?.pushNamed(
                    AppRoutes.panicAlertReceived,
                    arguments: Map<String, dynamic>.from(message.data),
                  );
                },
                child: const Text('Ver alerta'),
              ),
            ],
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == 'PANIC_ALERT') {
        navigatorKey.currentState?.pushNamed(
          AppRoutes.panicAlertReceived,
          arguments: Map<String, dynamic>.from(message.data),
        );
      }
    });
  } catch (e) {
    // Falla silenciosamente hasta que se ejecute flutterfire configure
    if (kDebugMode) print('⚠️ Firebase init skipped: $e');
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, this.initialRoute = AppRoutes.splash});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'batfinder',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          navigatorKey: navigatorKey,

          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },

          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: initialRoute,
        );
      },
    );
  }
}
