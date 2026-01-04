import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/card_action_button.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/info_item.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/route_indicator.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/status_badge.dart';

class OrderCard extends StatefulWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin, OrderCardActionsMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (_isInTransit) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isInTransit =>
      OrderStatusColors.isInTransit(widget.order.lastDeliveryStatus);

  Color get _accentColor =>
      OrderStatusColors.getAccentColor(widget.order.lastDeliveryStatus);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Hero(
      tag: 'all_order_${widget.order.orderId}_${widget.order.hashCode}',
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
            duration: const Duration(milliseconds: 100),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    _buildHeader(theme),
                    _buildBody(theme),
                    _buildActions(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: _accentColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 16,
                  color: _accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.orderIdWithStatus,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.order.deliveredDate?.isNotEmpty == true
                        ? 'Delivered: ${widget.order.deliveredDate}'
                        : 'In Progress',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatusBadge(
            status: widget.order.lastDeliveryStatus,
            color: _accentColor,
            pulseAnimation: _isInTransit ? _pulseAnimation : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          RouteIndicator(
            source: widget.order.source,
            destination: widget.order.destination,
          ),
          const SizedBox(height: 12),
          _buildReceiverDetails(theme),
          const SizedBox(height: 8),
          _buildChargesInfo(theme),
          const SizedBox(height: 8),
          _buildPackageInfo(theme),
        ],
      ),
    );
  }

  Widget _buildReceiverDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InfoItem(
                  label: 'Receiver',
                  value: widget.order.receiverName,
                  icon: Icons.person_rounded,
                ),
              ),
              Container(width: 1, height: 30, color: theme.dividerColor),
              Expanded(
                child: InfoItem(
                  label: 'Phone',
                  value: widget.order.receiverNumber,
                  icon: Icons.phone_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InfoItem(
            label: 'Address',
            value: widget.order.receiverAddress,
            icon: Icons.location_on_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildChargesInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InfoItem(
              label: 'COD Amount',
              value: 'Rs. ${widget.order.codCharge}',
              icon: Icons.payments_rounded,
              isPrice: true,
            ),
          ),
          Container(width: 1, height: 30, color: theme.dividerColor),
          Expanded(
            child: InfoItem(
              label: 'Delivery Charge',
              value: 'Rs. ${widget.order.deliveryCharge}',
              icon: Icons.local_shipping_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InfoItem(
        label: 'Package',
        value: widget.order.description,
        icon: Icons.inventory_2_outlined,
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CardActionButton(
            icon: Icons.call_rounded,
            label: 'Call',
            onTap: () => makePhoneCall(widget.order.receiverNumber),
          ),
          CardActionButton(
            icon: Icons.map_rounded,
            label: 'Track',
            onTap: () => openMaps(widget.order.receiverAddress),
          ),
          CardActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () => shareOrder(widget.order.orderIdWithStatus),
          ),
        ],
      ),
    );
  }
}
