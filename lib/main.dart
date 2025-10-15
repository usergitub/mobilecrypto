import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobileCrypto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins', // Assurez-vous d'ajouter cette police dans pubspec.yaml
        scaffoldBackgroundColor: AppColors.background,
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
    );
  }
}
