import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color lightBg = Color(0xFFF9FDF9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF1B5E20);      // Deep Forest Green
  static const Color lightSecondary = Color(0xFF5D4037);    // Soil Brown
  static const Color lightTextPrimary = Color(0xFF1B2E1E);  // Near Black Green
  static const Color lightTextSecondary = Color(0xFF4E342E); // Near Black Brown

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0C190E);            // Midnight Forest
  static const Color darkSurface = Color(0xFF162B1A);       // Dark Leaf
  static const Color darkPrimary = Color(0xFF81C784);       // Light Sage Green
  static const Color darkSecondary = Color(0xFFD7CCC8);     // Muted Clay
  static const Color darkTextPrimary = Color(0xFFF1F8E9);   // Off White Green
  static const Color darkTextSecondary = Color(0xFFEFEBE9); // Off White Brown

  // Severity & Semantic Colors (Both light and dark high contrast)
  static const Color success = Color(0xFF2E7D32);           // Leaf Green
  static const Color successBg = Color(0xFFE8F5E9);
  
  static const Color warning = Color(0xFFEF6C00);           // High-contrast Orange
  static const Color warningBg = Color(0xFFFFF3E0);
  
  static const Color danger = Color(0xFFC62828);            // Warning Red
  static const Color dangerBg = Color(0xFFFFEBEE);

  static const Color accent = Color(0xFFF57F17);            // Ripe Crop Gold
  static const Color cardShadow = Color(0x0A000000);

  // Generate Theme Data
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        surface: lightSurface,
        primary: lightPrimary,
        secondary: lightSecondary,
        error: danger,
      ),
      scaffoldBackgroundColor: lightBg,
      cardTheme: const CardThemeData(
        color: lightSurface,
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: lightTextPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightTextPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: lightTextPrimary),
        bodyLarge: TextStyle(fontSize: 18, color: lightTextPrimary, height: 1.4),
        bodyMedium: TextStyle(fontSize: 16, color: lightTextSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64), // Large touch targets
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        surface: darkSurface,
        primary: darkPrimary,
        secondary: darkSecondary,
        error: danger,
      ),
      scaffoldBackgroundColor: darkBg,
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkTextPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextPrimary),
        bodyLarge: TextStyle(fontSize: 18, color: darkTextPrimary, height: 1.4),
        bodyMedium: TextStyle(fontSize: 16, color: darkTextSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 64), // Large touch targets
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
