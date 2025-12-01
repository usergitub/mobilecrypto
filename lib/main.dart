import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/supabase_config.dart';
import 'utils/app_theme.dart';
import 'utils/notification_service.dart'; // ✅ IMPORT AJOUTÉ
import 'screens/auth/login_screen.dart';
import 'screens/auth/secret_code_screen.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.init();
  await NotificationService.init(); // ✅ UTILISER LE SERVICE

  // ✅ CHARGER LA SESSION LOCALE
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final savedPhone = prefs.getString("userPhone");

  // ✅ DÉTERMINATION DE LA PAGE DE DÉMARRAGE
  late Widget initialPage;

  // Si l'utilisateur n'est pas connecté, rediriger vers l'écran de connexion
  if (!isLoggedIn || savedPhone == null) {
    initialPage = const SignUpScreen();
  } else {
    // Utilisateur connecté, vérifier le PIN
    initialPage = SecretCodeScreen(
      phoneNumber: savedPhone,
      isCreating: false,
    );
  }

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobileCrypto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SpaceGrotesk',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
      home: initialPage,
    );
  }
}