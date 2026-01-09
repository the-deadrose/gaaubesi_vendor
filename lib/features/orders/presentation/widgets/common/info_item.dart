import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';

/// Reusable info item widget for displaying labeled data with an icon.
/// Used across all order card types for consistent information display.
class InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPrice;
  final int maxLines;
  final Color? valueColor;

  const InfoItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isPrice = false,
    this.maxLines = 1,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor =
        valueColor ??
        (isPrice ? AppTheme.successGreen : theme.textTheme.bodyMedium?.color);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: theme.brightness == Brightness.dark
                    ? AppTheme.powerBlue
                    : AppTheme.powerBlue.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.brightness == Brightness.dark
                      ? AppTheme.powerBlue.withValues(alpha: 0.8)
                      : AppTheme.powerBlue.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: displayColor,
              letterSpacing: 0.1,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
