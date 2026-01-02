import 'package:flutter/material.dart';

/// A widget that displays a label-value pair for order details.
class OrderDetailInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const OrderDetailInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '-' : value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: content,
    );
  }
}

/// A horizontal row with two info tiles.
class OrderDetailInfoRow extends StatelessWidget {
  final String label1;
  final String value1;
  final String label2;
  final String value2;
  final Color? value1Color;
  final Color? value2Color;

  const OrderDetailInfoRow({
    super.key,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
    this.value1Color,
    this.value2Color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OrderDetailInfoTile(
            label: label1,
            value: value1,
            valueColor: value1Color,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: OrderDetailInfoTile(
              label: label2,
              value: value2,
              valueColor: value2Color,
            ),
          ),
        ),
      ],
    );
  }
}
