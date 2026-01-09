import 'package:flutter/material.dart';

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
    Theme.of(context);

    Widget badge = Text(
      status,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 10,
        letterSpacing: 0.1,
      ),
    );

    if (pulseAnimation != null) {
      return ScaleTransition(scale: pulseAnimation!, child: badge);
    }

    return badge;
  }
}
