import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/theme/text_styles.dart';

class AppTheme {
  static const _marianBlue = Color(0xFF21428A);
  static const _rojo = Color(0xFFD91F2A);
  static const _blackBean = Color(0xFF3C1518);
  static const _powerBlue = Color(0xFFA9B4C2);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _marianBlue,
      onPrimary: Colors.white,
      secondary: _rojo,
      onSecondary: Colors.white,
      tertiary: _blackBean,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: _blackBean,
      error: _rojo,
      onError: Colors.white,
      outline: _powerBlue,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: _marianBlue),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: _marianBlue),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: _blackBean),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: _blackBean),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: _blackBean),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: _blackBean),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: _blackBean),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: _marianBlue),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _powerBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _powerBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _marianBlue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _marianBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _marianBlue,
      onPrimary: Colors.white,
      secondary: _rojo,
      onSecondary: Colors.white,
      tertiary: _powerBlue,
      onTertiary: _blackBean,
      surface: _blackBean,
      onSurface: Colors.white,
      error: _rojo,
      onError: Colors.white,
      outline: _powerBlue,
    ),
    scaffoldBackgroundColor: const Color(
      0xFF1A090A,
    ), // Darker shade of Black Bean
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.white),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: Colors.white),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: Colors.white,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _powerBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _powerBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _rojo, width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _rojo, // Use secondary color for primary action in dark mode for contrast
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
  );
}
