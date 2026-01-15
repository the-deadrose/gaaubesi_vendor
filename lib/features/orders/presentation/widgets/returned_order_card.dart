import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/status_badge.dart';

class ReturnedOrderCard extends StatefulWidget {
  final ReturnedOrderEntity order;
  final VoidCallback? onTap;

  const ReturnedOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  State<ReturnedOrderCard> createState() => _ReturnedOrderCardState();
}

class _ReturnedOrderCardState extends State<ReturnedOrderCard>
    with OrderCardActionsMixin {
  bool _isPressed = false;
  static const _accentColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: 'returned_order_${widget.order.orderId}_${widget.order.hashCode}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _buildSimpleList(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order ID
        Row(
          children: [
            Text(
              'ORD${widget.order.orderId}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.marianBlue,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            const StatusBadge(
              status: 'Returned',
              color: _accentColor,
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Destination
        Row(
          children: [
            Text(
              widget.order.destination,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Customer Name and Phone
        Row(
          children: [
            Text(
              '${widget.order.customerName} • ${widget.order.customerNumber}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // COD Charge
        Text(
          'COD: ${widget.order.codCharge}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
