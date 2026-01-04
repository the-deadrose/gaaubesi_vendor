import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledColor;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? shadow;
  final bool showGradient;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.width,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.backgroundColor,
    this.foregroundColor,
    this.disabledColor,
    this.borderRadius,
    this.shadow,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine colors based on theme and parameters
    final bgColor = backgroundColor ?? colorScheme.primary;
    final fgColor = foregroundColor ?? colorScheme.onPrimary;
    final disabledBgColor =
        disabledColor ??
        (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300);
    final disabledFgColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    // Determine gradient colors for enabled state
    final gradientColors = showGradient && onPressed != null && !isLoading
        ? [bgColor, Color.lerp(bgColor, Colors.black, 0.1) ?? bgColor]
        : null;

    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: onPressed != null && !isLoading
            ? shadow ??
                  [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: fgColor,
          disabledBackgroundColor: disabledBgColor,
          disabledForegroundColor: disabledFgColor,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            gradient: gradientColors != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                    stops: const [0.0, 1.0],
                  )
                : null,
            color: onPressed == null || isLoading
                ? disabledBgColor
                : gradientColors == null
                ? bgColor
                : null,
          ),
          child: Center(
            child: Padding(
              padding: padding,
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(
                          onPressed != null ? fgColor : disabledFgColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 20,
                            color: onPressed != null
                                ? fgColor
                                : disabledFgColor,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: onPressed != null
                                  ? fgColor
                                  : disabledFgColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Secondary button variant
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.width,
    this.height = 56,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? colorScheme.primary, width: 2),
        boxShadow: [
          if (onPressed != null && !isLoading)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor ?? colorScheme.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: isDarkMode
              ? Colors.grey.shade600
              : Colors.grey.shade400,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        textColor ?? colorScheme.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: onPressed != null
                              ? textColor ?? colorScheme.primary
                              : (isDarkMode
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: onPressed != null
                                ? textColor ?? colorScheme.primary
                                : (isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
