import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/theme/text_styles.dart';

///this is made according to the brand guidelines provided by the client don't change the colors unless you have permission from the client

class AppTheme {
  // ─────────────────────────────────────────────
  // Brand Colors (DO NOT CHANGE)
  // ─────────────────────────────────────────────
  static const marianBlue = Color(0xFF21428A); // Primary
  static const rojo = Color(0xFFD91F2A); // Secondary / Error
  static const blackBean = Color(0xFF3C1518); // Dark text / surface
  static const powerBlue = Color(0xFFA9B4C2); // Outline / borders
  static const whiteSmoke = Color(0xFFF5F5F5); // Light background

  // ─────────────────────────────────────────────
  // Semantic Utility Colors (UI only)
  // ─────────────────────────────────────────────
  static const successGreen = Color(0xFF28A745);
  static const warningYellow = Color(0xFFFFC107);
  static const infoBlue = Color(0xFF17A2B8);

  static const lightGray = Color(0xFFF8F9FA);
  static const darkGray = Color(0xFF6C757D);
  static const disabledGray = Color(0xFFE9ECEF);

  // ─────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: marianBlue,
      onPrimary: Colors.white,

      secondary: rojo,
      onSecondary: Colors.white,

      tertiary: powerBlue,
      onTertiary: blackBean,

      surface: Colors.white,
      onSurface: blackBean,

      error: rojo,
      onError: Colors.white,

      outline: powerBlue,
    ),

    scaffoldBackgroundColor: Colors.white,

    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: marianBlue),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: marianBlue),

      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: blackBean),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: blackBean),

      titleLarge: AppTextStyles.titleLarge.copyWith(color: blackBean),

      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: blackBean),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: blackBean),

      labelLarge: AppTextStyles.labelLarge.copyWith(color: marianBlue),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: powerBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: powerBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: marianBlue, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: marianBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),

    extensions: const [
      AdditionalColors(
        success: successGreen,
        warning: warningYellow,
        info: infoBlue,
        accent: rojo,
        lightGray: lightGray,
        darkGray: darkGray,
        disabled: disabledGray,
      ),
    ],
  );

  // ─────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: marianBlue,
      onPrimary: Colors.white,

      secondary: rojo,
      onSecondary: Colors.white,

      tertiary: powerBlue,
      onTertiary: Colors.white,

      surface: blackBean,
      onSurface: Colors.white,

      error: rojo,
      onError: Colors.white,

      outline: powerBlue,
    ),

    scaffoldBackgroundColor: blackBean,

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
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: powerBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: rojo, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: rojo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),

    extensions: const [
      AdditionalColors(
        success: Color(0xFF20D96F),
        warning: Color(0xFFFFD166),
        info: Color(0xFF4CC9F0),
        accent: rojo,
        lightGray: Color(0xFF343A40),
        darkGray: Color(0xFFADB5BD),
        disabled: Color(0xFF495057),
      ),
    ],
  );
}

// ─────────────────────────────────────────────
// THEME EXTENSION
// ─────────────────────────────────────────────
class AdditionalColors extends ThemeExtension<AdditionalColors> {
  const AdditionalColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.accent,
    required this.lightGray,
    required this.darkGray,
    required this.disabled,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color accent;
  final Color lightGray;
  final Color darkGray;
  final Color disabled;

  @override
  AdditionalColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? accent,
    Color? lightGray,
    Color? darkGray,
    Color? disabled,
  }) {
    return AdditionalColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      accent: accent ?? this.accent,
      lightGray: lightGray ?? this.lightGray,
      darkGray: darkGray ?? this.darkGray,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  AdditionalColors lerp(ThemeExtension<AdditionalColors>? other, double t) {
    if (other is! AdditionalColors) return this;

    return AdditionalColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      lightGray: Color.lerp(lightGray, other.lightGray, t)!,
      darkGray: Color.lerp(darkGray, other.darkGray, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
    );
  }
}

// ─────────────────────────────────────────────
// EXTENSION ACCESSOR
// ─────────────────────────────────────────────
extension AdditionalColorsX on ThemeData {
  AdditionalColors get extra =>
      extension<AdditionalColors>() ??
      const AdditionalColors(
        success: AppTheme.successGreen,
        warning: AppTheme.warningYellow,
        info: AppTheme.infoBlue,
        accent: AppTheme.rojo,
        lightGray: AppTheme.lightGray,
        darkGray: AppTheme.darkGray,
        disabled: AppTheme.disabledGray,
      );
}
