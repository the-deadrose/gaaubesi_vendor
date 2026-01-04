import 'package:flutter/material.dart';

/// Visual indicator for source-to-destination route.
/// Shows a vertical line with dots at start and end points.
class RouteIndicator extends StatelessWidget {
  final String source;
  final String destination;
  final Color sourceColor;
  final Color destinationColor;

  const RouteIndicator({
    super.key,
    required this.source,
    required this.destination,
    this.sourceColor = Colors.green,
    this.destinationColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            _Dot(color: sourceColor),
            Container(
              height: 24,
              width: 2,
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sourceColor,
                    destinationColor.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            _Dot(color: destinationColor),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),
              Text(
                destination,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}
