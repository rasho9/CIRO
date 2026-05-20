import 'package:flutter/material.dart';

class AppColors {
  static const Color deepNavy = Color(0xFF0A0E2C);
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color redAlert = Color(0xFFFF3B30);
  static const Color purpleGlow = Color(0xFFB388FF);
  static const Color glassWhite = Colors.white70;

  static const Gradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, Color(0xFF1F2C51)],
  );

  static const Gradient neon = LinearGradient(
    colors: [cyanAccent, purpleGlow],
  );
}
