import 'package:flutter/material.dart';

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
        (isPrice ? Colors.green : theme.textTheme.bodyMedium?.color);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: theme.hintColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: theme.hintColor),
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
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
