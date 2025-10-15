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
  static const TextStyle heading1 = TextStyle(
    color: AppColors.text,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle body = TextStyle(
    color: AppColors.textFaded,
    fontSize: 16,
  );
   static const TextStyle link = TextStyle(
    color: Color(0xFF60A5FA),
    fontSize: 14,
    decoration: TextDecoration.underline,
  );
}
