import 'package:flutter/material.dart';

/// Reusable status badge widget with optional pulse animation.
/// Used to display order status with appropriate color coding.
class StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  final Animation<double>? pulseAnimation;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    required this.color,
    this.pulseAnimation,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );

    if (pulseAnimation != null) {
      return ScaleTransition(scale: pulseAnimation!, child: badge);
    }

    return badge;
  }
}
