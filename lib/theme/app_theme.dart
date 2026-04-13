import 'package:flutter/material.dart';

class AppTheme {
  // Dental Clinic Color Palette
  static const Color primary = Color(0xFF61CFCF);      // Teal
  static const Color mint = Color(0xFFBDDBD1);         // Mint green
  static const Color lightGray = Color(0xFFE7E9E3);    // Light gray
  static const Color cream = Color(0xFFFBF9F1);        // Cream/off-white
  static const Color lightBlueGray = Color(0xFFE8F0F1); // Light blue-gray
  static const Color lightBlue = Color(0xFFC7E7EC);    // Light blue

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: mint,
        onSecondary: primary,
        surface: cream,
        onSurface: primary,
        error: const Color(0xFFB00020),
        onError: Colors.white,
        primaryContainer: lightBlue,
        onPrimaryContainer: primary,
        secondaryContainer: lightBlueGray,
        onSecondaryContainer: primary,
        outline: mint,
        outlineVariant: lightGray,
        surfaceContainerHighest: lightGray,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        elevation: 0,
        foregroundColor: primary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightGray),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: mint,
        onPrimary: primary,
        secondary: lightBlue,
        onSecondary: primary,
        surface: const Color(0xFF1A2422),
        onSurface: lightGray,
        error: const Color(0xFFCF6679),
        onError: Colors.black,
        primaryContainer: primary,
        onPrimaryContainer: mint,
        secondaryContainer: const Color(0xFF2A3E3C),
        onSecondaryContainer: lightGray,
        outline: const Color(0xFF3A5452),
        outlineVariant: const Color(0xFF2A3E3C),
        surfaceContainerHighest: const Color(0xFF2A3E3C),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A2422),
        elevation: 0,
        foregroundColor: lightGray,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A3E3C)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: mint,
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A5452)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A5452)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mint, width: 2),
        ),
      ),
    );
  }
}
