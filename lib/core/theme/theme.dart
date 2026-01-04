import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/theme/text_styles.dart';

class AppTheme {
  // Primary Color Palette
  static const _marianBlue = Color(0xFF21428A);
  static const _marianBlueLight = Color(0xFF4A67B8);
  static const financialbox = [Color(0xFF1A1F38), Color(0xFF2C3E50)];

  // Secondary Color Palette
  static const _rojo = Color(0xFFD91F2A);
  static const _rojoLight = Color(0xFFFF5252);

  // Neutral & Background Colors
  static const _blackBean = Color(0xFF3C1518);
  static const _blackBeanLight = Color(0xFF5A2C2F);

  // Accent & Utility Colors
  static const _powerBlue = Color(0xFFA9B4C2);
  static const _powerBlueLight = Color(0xFFD8DFE8);
  static const _powerBlueDark = Color(0xFF7A899C);

  // Success Colors
  static const _successGreen = Color(0xFF2E7D32);
  static const _successGreenLight = Color(0xFF4CAF50);

  // Warning Colors
  static const _warningOrange = Color(0xFFF57C00);
  static const _warningOrangeLight = Color(0xFFFF9800);

  // Info Colors
  static const _infoBlue = Color(0xFF0288D1);
  static const _infoBlueLight = Color(0xFF03A9F4);

  // Surface & Background Variations
  static const _surfaceWhite = Color(0xFFFFFFFF);
  static const _surfaceLight = Color(0xFFF5F5F5);

  // Text Colors
  static const _textPrimary = Color(0xFF212121);
  static const _textSecondary = Color(0xFF757575);
  static const _textDisabled = Color(0xFF9E9E9E);

  // Gradient Colors
  static const _primaryGradient = LinearGradient(
    colors: [_marianBlue, _marianBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _secondaryGradient = LinearGradient(
    colors: [_rojo, _rojoLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const _lightShadowColor = Color(
    0x14000000,
  ); // Colors.black.withOpacity(0.08)
  static const _mediumShadowColor = Color(
    0x26000000,
  ); // Colors.black.withOpacity(0.15)

  // Status Colors Map (for easy access)
  static Map<String, Color> get statusColors => {
    'success': _successGreen,
    'successLight': _successGreenLight,
    'warning': _warningOrange,
    'warningLight': _warningOrangeLight,
    'error': _rojo,
    'errorLight': _rojoLight,
    'info': _infoBlue,
    'infoLight': _infoBlueLight,
  };

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _marianBlue,
      primaryContainer: _marianBlueLight,
      onPrimary: Colors.white,
      secondary: _rojo,
      secondaryContainer: _rojoLight,
      onSecondary: Colors.white,
      tertiary: _blackBean,
      tertiaryContainer: _blackBeanLight,
      onTertiary: Colors.white,
      surface: _surfaceWhite,
      surfaceContainerHighest: _surfaceLight,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      error: _rojo,
      errorContainer: _rojoLight,
      onError: Colors.white,
      outline: _powerBlue,
      outlineVariant: _powerBlueLight,
      shadow: _lightShadowColor,
      scrim: Colors.black54,
    ),
    scaffoldBackgroundColor: _surfaceWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: _surfaceWhite,
      foregroundColor: _marianBlue,
      elevation: 0,
      surfaceTintColor: _surfaceWhite,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(
        color: _marianBlue,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: _surfaceWhite,
      elevation: 2,
      shadowColor: _lightShadowColor,
      surfaceTintColor: _surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: _marianBlue),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: _marianBlue),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: _marianBlue),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: _textPrimary),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: _textPrimary,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: _textPrimary),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: _textPrimary),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: _textPrimary),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: _textSecondary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: _textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: _textPrimary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: _textSecondary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: _marianBlue),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: _marianBlue),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: _marianBlue),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _rojo),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _rojo, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _textDisabled),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: _textDisabled),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: _rojo),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _marianBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _powerBlue,
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: _mediumShadowColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _marianBlue,
        side: const BorderSide(color: _marianBlue),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _marianBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: _powerBlueLight,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _powerBlueLight.withValues(alpha: 0.2),
      selectedColor: _marianBlue,
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: _textPrimary),
      secondaryLabelStyle: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _textPrimary,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      actionTextColor: _rojoLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceWhite,
      selectedItemColor: _marianBlue,
      unselectedItemColor: _textSecondary,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _rojo,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _marianBlueLight,
      primaryContainer: _marianBlue,
      onPrimary: Colors.white,
      secondary: _rojoLight,
      secondaryContainer: _rojo,
      onSecondary: Colors.white,
      tertiary: _powerBlue,
      tertiaryContainer: _powerBlueDark,
      onTertiary: _blackBean,
      surface: Color(0xFF121212),
      surfaceContainerHighest: Color(0xFF1E1E1E),
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white70,
      error: _rojoLight,
      errorContainer: _rojo,
      onError: Colors.white,
      outline: _powerBlueDark,
      outlineVariant: _powerBlue,
      shadow: Colors.black,
      scrim: Colors.black87,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: const Color(0xFF1E1E1E),
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shadowColor: Colors.black,
      surfaceTintColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.white),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: Colors.white),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: Colors.white),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: Colors.white,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: Colors.white),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: Colors.white70),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: Colors.white),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: Colors.white),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _powerBlueDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _powerBlueDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _rojoLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _rojoLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _rojoLight, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: _rojoLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _rojoLight,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade800,
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Colors.black,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _rojoLight,
        side: const BorderSide(color: _rojoLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _rojoLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF333333),
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      selectedColor: _rojoLight,
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      secondaryLabelStyle: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF333333),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      actionTextColor: _rojoLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: _rojoLight,
      unselectedItemColor: Colors.white70,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _rojoLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Additional theme extensions for custom widgets
  static ThemeExtensions get extensions => ThemeExtensions(
    gradients: ThemeGradients(
      primary: _primaryGradient,
      secondary: _secondaryGradient,
    ),
    statusColors: statusColors,
  );

  // Light theme with extensions
  static ThemeData get lightThemeWithExtensions {
    return lightTheme.copyWith(
      extensions: [
        _CustomThemeExtension(
          gradients: const _ThemeGradients(
            primary: _primaryGradient,
            secondary: _secondaryGradient,
          ),
          statusColors: statusColors,
        ),
      ],
    );
  }

  // Dark theme with extensions
  static ThemeData get darkThemeWithExtensions {
    return darkTheme.copyWith(
      extensions: [
        _CustomThemeExtension(
          gradients: const _ThemeGradients(
            primary: _primaryGradient,
            secondary: _secondaryGradient,
          ),
          statusColors: statusColors,
        ),
      ],
    );
  }
}

// Custom theme extensions for additional flexibility
@immutable
class _CustomThemeExtension extends ThemeExtension<_CustomThemeExtension> {
  final _ThemeGradients gradients;
  final Map<String, Color> statusColors;

  const _CustomThemeExtension({
    required this.gradients,
    required this.statusColors,
  });

  @override
  _CustomThemeExtension copyWith({
    _ThemeGradients? gradients,
    Map<String, Color>? statusColors,
  }) {
    return _CustomThemeExtension(
      gradients: gradients ?? this.gradients,
      statusColors: statusColors ?? this.statusColors,
    );
  }

  @override
  _CustomThemeExtension lerp(
    ThemeExtension<_CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! _CustomThemeExtension) {
      return this;
    }
    return _CustomThemeExtension(
      gradients: _ThemeGradients(
        primary: LinearGradient.lerp(
          gradients.primary,
          other.gradients.primary,
          t,
        )!,
        secondary: LinearGradient.lerp(
          gradients.secondary,
          other.gradients.secondary,
          t,
        )!,
      ),
      statusColors: other.statusColors,
    );
  }
}

@immutable
class _ThemeGradients {
  final LinearGradient primary;
  final LinearGradient secondary;

  const _ThemeGradients({required this.primary, required this.secondary});
}

// Legacy classes for backward compatibility
class ThemeExtensions {
  final ThemeGradients gradients;
  final Map<String, Color> statusColors;

  ThemeExtensions({required this.gradients, required this.statusColors});
}

class ThemeGradients {
  final LinearGradient primary;
  final LinearGradient secondary;

  ThemeGradients({required this.primary, required this.secondary});
}
