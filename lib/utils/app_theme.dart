import 'package:flutter/material.dart';

// Couleurs de l'application
class AppColors {
  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textFaded = Color(0xFF94A3B8);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color border = Color(0xFF334155);
}

// Styles de texte de l'application
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: 'SpaceGrotesk',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontFamily: 'SpaceGrotesk',
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
    fontFamily: 'SpaceGrotesk',
  );

  static const TextStyle bodyFaded = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textFaded,
    fontFamily: 'SpaceGrotesk',
  );

  static const TextStyle link = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryGreen,
    fontFamily: 'SpaceGrotesk',
  );
}

class AppTheme {
  // Couleur principale pour votre application (un bleu crypto)
  static const Color primaryColor = Color(0xFF007BFF); 
  // Arrière-plan sombre/noir pour le thème Dark
  static const Color darkBackground = Color(0xFF1A1A2E); 
  // Couleur des cartes (légèrement plus claire que l'arrière-plan)
  static const Color darkCardColor = Color(0xFF2C2C54); 
  // Texte principal blanc
  static const Color lightTextColor = Color(0xFFFFFFFF); 

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // Couleurs primaires
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: const Color(0xFF88D498), // Couleur d'accentuation (pour les gains)
      surface: darkBackground, // Arrière-plan
      onSurface: lightTextColor, // Texte
      error: Colors.redAccent,
    ),
    // Couleurs de fond
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardColor, // Couleur des tuiles/cartes
    
    // Configuration de l'AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: lightTextColor),
      titleTextStyle: TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    // Configuration de la barre de navigation inférieure
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 0,
    ),
    
    // Configuration des boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: lightTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    ),
    
    // Configuration de l'indicateur de chargement
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),
  );
}