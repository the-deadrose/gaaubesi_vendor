import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/status_badge.dart';

class RedirectedOrderCard extends StatefulWidget {
  final RedirectedOrderItem order;
  final VoidCallback? onTap;

  const RedirectedOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  State<RedirectedOrderCard> createState() => _RedirectedOrderCardState();
}

class _RedirectedOrderCardState extends State<RedirectedOrderCard>
    with OrderCardActionsMixin {
  bool _isPressed = false;
  static const _accentColor = Colors.purple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: 'redirected_order_${widget.order.childOrderId}_${widget.order.hashCode}',
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
              'ORD${widget.order.parentOrderId}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.marianBlue,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            const StatusBadge(
              status: 'Redirected',
              color: _accentColor,
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Parent and Child Order
        Row(
          children: [
            Text(
              'Parent: ${widget.order.parentOrderId}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              'Child: ${widget.order.childOrderId}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.marianBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Child Order Status
        Row(
          children: [
            Text(
              'Status: ${widget.order.childOrderStatus}',
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
        
        // Vendor and Creation Date
        Row(
          children: [
            Text(
              'Vendor: ${widget.order.vendorName}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              'Date: ${widget.order.createdOn.day}/${widget.order.createdOn.month}/${widget.order.createdOn.year}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.marianBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
