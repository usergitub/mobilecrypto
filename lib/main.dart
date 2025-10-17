import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'utils/supabase_config.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧩 Initialisation de Supabase
  await SupabaseConfig.init();

  // 🔔 Initialisation des notifications locales
  await _initNotifications();

  runApp(const MyApp());
}

// 🧠 Fonction d’initialisation des notifications
Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await notifications.initialize(initSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobileCrypto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          background: AppColors.background,
        ),
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
    );
  }
}

// 📲 Fonction pour afficher une notification OTP
Future<void> showOtpNotification(String code) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'otp_channel',
    'OTP Notifications',
    channelDescription: 'Affiche les OTP envoyés pour la vérification',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notifDetails =
      NotificationDetails(android: androidDetails);

  await notifications.show(
    0,
    'Code de vérification MobileCrypto',
    'Votre code est : $code',
    notifDetails,
  );
}
