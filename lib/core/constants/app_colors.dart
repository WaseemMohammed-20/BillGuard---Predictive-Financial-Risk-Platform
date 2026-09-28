import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF7F3EF);
  static const Color backgroundAlt = Color(0xFFF1EAE4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFDF9F7);
  static const Color border = Color(0xFFE9E1DB);
  static const Color textPrimary = Color(0xFF1F1A1A);
  static const Color textSecondary = Color(0xFF6A5F5D);
  static const Color accent = Color(0xFF8E2D2D);
  static const Color accentSoft = Color(0xFFF5E7E6);
  static const Color success = Color(0xFF345A4B);
  static const Color warning = Color(0xFF9B7A3D);
  static const Color danger = Color(0xFFB53232);
  static const Color critical = Color(0xFF8D2A2A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color graphLine = Color(0xFF8E2D2D);
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF9F5F2)],
  );
}
