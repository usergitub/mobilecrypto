import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);
  static const Color primaryGreen = Color(0xFF34D399);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color text = Colors.white;
  static const Color textFaded = Color(0xFF94A3B8);
  static const Color border = Color(0xFF334155);
}

class AppTextStyles {
  static const heading1 = TextStyle(
    color: AppColors.text,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const heading2 = TextStyle(
    color: AppColors.text,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 14,
  );

  static const bodyFaded = TextStyle(
    color: AppColors.textFaded,
    fontSize: 14,
  );

  static const link = TextStyle(
    color: AppColors.primaryGreen,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );
}
