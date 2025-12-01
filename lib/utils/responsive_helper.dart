import 'package:flutter/material.dart';

/// Helper pour rendre l'application responsive
class ResponsiveHelper {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getWidth(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  static double getHeight(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  /// Padding horizontal adaptatif (4% de l'écran, min 16, max 32)
  static double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    final padding = width * 0.04;
    return padding.clamp(16.0, 32.0);
  }

  /// Padding vertical adaptatif
  static double verticalPadding(BuildContext context) {
    final height = screenHeight(context);
    return (height * 0.02).clamp(8.0, 24.0);
  }

  /// Taille de police responsive
  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    // Base sur un écran de 360px (petit écran)
    final scale = (width / 360).clamp(0.85, 1.3);
    return baseSize * scale;
  }

  /// Espacement adaptatif
  static double spacing(BuildContext context, double baseSpacing) {
    final height = screenHeight(context);
    // Base sur un écran de 800px de hauteur
    final scale = (height / 800).clamp(0.8, 1.2);
    return baseSpacing * scale;
  }

  /// Taille d'icône responsive
  static double iconSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    final scale = (width / 360).clamp(0.9, 1.2);
    return baseSize * scale;
  }

  /// Taille de logo responsive
  static double logoSize(BuildContext context) {
    final width = screenWidth(context);
    return (width * 0.2).clamp(60.0, 100.0);
  }

  /// Hauteur de bouton responsive
  static double buttonHeight(BuildContext context) {
    final height = screenHeight(context);
    return (height * 0.07).clamp(48.0, 60.0);
  }

  /// Taille de carte responsive
  static double cardHeight(BuildContext context, double percentage) {
    final height = screenHeight(context);
    return height * (percentage / 100);
  }

  /// Vérifier si c'est un petit écran
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 360;
  }

  /// Vérifier si c'est un grand écran
  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) > 600;
  }

  /// Margin adaptatif
  static EdgeInsets margin(BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      final margin = spacing(context, all);
      return EdgeInsets.all(margin);
    }
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? spacing(context, horizontal) : 0,
      vertical: vertical != null ? spacing(context, vertical) : 0,
    );
  }

  /// Padding adaptatif
  static EdgeInsets padding(BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      final padding = spacing(context, all);
      return EdgeInsets.all(padding);
    }
    return EdgeInsets.symmetric(
      horizontal: horizontal != null 
          ? spacing(context, horizontal) 
          : horizontalPadding(context),
      vertical: vertical != null ? spacing(context, vertical) : 0,
    );
  }
}

