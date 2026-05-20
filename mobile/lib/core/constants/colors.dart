import 'package:flutter/material.dart';

class AppColors {
  // Primary dark navy background
  static const Color background = Color(0xFF0A0E21);
  // Accent teal
  static const Color teal = Color(0xFF00BFA5);
  // Lighter surface for cards
  static const Color cardSurface = Color(0xFF1E2236);
  // Text colors
  static const Color primaryText = Colors.white70;
  static const Color secondaryText = Colors.white38;
  // Danger red for zones
  static const Color dangerRed = Color(0xFFFF5252);
  // Gradient start/end for hero section
  static const Gradient heroGradient = LinearGradient(
    colors: [Color(0xFF001F54), Color(0xFF006064)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
