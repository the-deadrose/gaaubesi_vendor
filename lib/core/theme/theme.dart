import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/theme/text_styles.dart';

class AppTheme {
  // Primary colors (keeping as is)
  static const _marianBlue = Color(0xFF21428A);
  static const _rojo = Color(0xFFD91F2A);
  static const _blackBean = Color(0xFF3C1518);
  static const _powerBlue = Color(0xFFA9B4C2);
  
  // Additional colors
  static const _successGreen = Color(0xFF28A745);
  static const _warningYellow = Color(0xFFFFC107);
  static const _infoBlue = Color(0xFF17A2B8);
  static const _lightGray = Color(0xFFF8F9FA);
  static const _darkGray = Color(0xFF6C757D);
  static const _disabledGray = Color(0xFFE9ECEF);
  static const _accentPurple = Color(0xFF6F42C1);
  static const _accentOrange = Color(0xFFFD7E14);
  static const _accentCyan = Color(0xFF20C997);
  
  // Semantic color extensions
  static const success = _successGreen;
  static const warning = _warningYellow;
  static const info = _infoBlue;
  static const accent = _accentPurple;

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
    // Additional theme extensions
    extensions: const <ThemeExtension<dynamic>>[
      AdditionalColors(
        success: _successGreen,
        warning: _warningYellow,
        info: _infoBlue,
        accent: _accentPurple,
        lightGray: _lightGray,
        darkGray: _darkGray,
        disabled: _disabledGray,
        orange: _accentOrange,
        cyan: _accentCyan,
      ),
    ],
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
    scaffoldBackgroundColor: const Color(0xFF1A090A),
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
      fillColor: Colors.white.withAlpha(5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _rojo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    // Additional theme extensions for dark mode
    extensions: const <ThemeExtension<dynamic>>[
      AdditionalColors(
        success: Color(0xFF20D96F),
        warning: Color(0xFFFFD166),
        info: Color(0xFF4CC9F0),
        accent: Color(0xFF9D4EDD),
        lightGray: Color(0xFF343A40),
        darkGray: Color(0xFFADB5BD),
        disabled: Color(0xFF495057),
        orange: Color(0xFFFF9F1C),
        cyan: Color(0xFF06D6A0),
      ),
    ],
  );
}

// Custom ThemeExtension for additional colors
class AdditionalColors extends ThemeExtension<AdditionalColors> {
  const AdditionalColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.accent,
    required this.lightGray,
    required this.darkGray,
    required this.disabled,
    required this.orange,
    required this.cyan,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color accent;
  final Color lightGray;
  final Color darkGray;
  final Color disabled;
  final Color orange;
  final Color cyan;

  @override
  ThemeExtension<AdditionalColors> copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? accent,
    Color? lightGray,
    Color? darkGray,
    Color? disabled,
    Color? orange,
    Color? cyan,
  }) {
    return AdditionalColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      accent: accent ?? this.accent,
      lightGray: lightGray ?? this.lightGray,
      darkGray: darkGray ?? this.darkGray,
      disabled: disabled ?? this.disabled,
      orange: orange ?? this.orange,
      cyan: cyan ?? this.cyan,
    );
  }

  @override
  ThemeExtension<AdditionalColors> lerp(
    ThemeExtension<AdditionalColors>? other,
    double t,
  ) {
    if (other is! AdditionalColors) {
      return this;
    }

    return AdditionalColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      lightGray: Color.lerp(lightGray, other.lightGray, t)!,
      darkGray: Color.lerp(darkGray, other.darkGray, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
    );
  }
}

// Helper extension to easily access additional colors
extension AdditionalColorsExtension on ThemeData {
  AdditionalColors get additionalColors =>
      extension<AdditionalColors>() ?? const AdditionalColors(
        success: Color(0xFF28A745),
        warning: Color(0xFFFFC107),
        info: Color(0xFF17A2B8),
        accent: Color(0xFF6F42C1),
        lightGray: Color(0xFFF8F9FA),
        darkGray: Color(0xFF6C757D),
        disabled: Color(0xFFE9ECEF),
        orange: Color(0xFFFD7E14),
        cyan: Color(0xFF20C997),
      );
}