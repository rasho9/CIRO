import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.deepNavy,
    primaryColor: AppColors.cyanAccent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.cyanAccent,
      secondary: AppColors.purpleGlow,
      surface: AppColors.deepNavy,
      background: AppColors.deepNavy,
      error: AppColors.redAlert,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: AppColors.cyanAccent,
      unselectedItemColor: AppColors.glassWhite,
      showUnselectedLabels: true,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 14, color: Colors.white),
    ),
  );
}
