import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderCard extends StatefulWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
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

    // Start pulse animation for in-transit orders
    if (_isInTransit) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isInTransit {
    final status = widget.order.lastDeliveryStatus.toLowerCase();
    return status.contains('transit') || status.contains('process');
  }

  Color get _accentColor {
    final status = widget.order.lastDeliveryStatus.toLowerCase();
    if (status.contains('delivered') || status.contains('success')) {
      return Colors.green;
    } else if (status.contains('cancel') || status.contains('return')) {
      return Colors.red;
    } else if (status.contains('pending') || status.contains('hold')) {
      return Colors.orange;
    } else if (status.contains('process') || status.contains('transit')) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  void _makePhoneCall() async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse('tel:${widget.order.receiverNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openMaps() async {
    HapticFeedback.mediumImpact();
    // Create a simple Google Maps URL with the address
    final address = Uri.encodeComponent(widget.order.receiverAddress);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$address',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareOrder() {
    HapticFeedback.lightImpact();
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${widget.order.orderIdWithStatus}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Hero(
      tag: 'order_${widget.order.orderId}',
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
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.05),
                        border: Border(
                          bottom: BorderSide(
                            color: _accentColor.withOpacity(0.1),
                          ),
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
                                      color: _accentColor.withOpacity(0.2),
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
                          _StatusBadge(
                            status: widget.order.lastDeliveryStatus,
                            color: _accentColor,
                            pulseAnimation: _isInTransit
                                ? _pulseAnimation
                                : null,
                          ),
                        ],
                      ),
                    ),

                    // Body Section
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Route
                          Row(
                            children: [
                              Column(
                                children: [
                                  _Dot(color: Colors.green),
                                  Container(
                                    height: 24,
                                    width: 2,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.green,
                                          Colors.red.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _Dot(color: Colors.red),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.order.source,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      widget.order.destination,
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
                          ),
                          const SizedBox(height: 12),

                          // Receiver Details
                          Container(
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
                                      child: _InfoItem(
                                        label: 'Receiver',
                                        value: widget.order.receiverName,
                                        icon: Icons.person_rounded,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 30,
                                      color: theme.dividerColor,
                                    ),
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'Phone',
                                        value: widget.order.receiverNumber,
                                        icon: Icons.phone_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _InfoItem(
                                  label: 'Address',
                                  value: widget.order.receiverAddress,
                                  icon: Icons.location_on_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Charges Info
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _InfoItem(
                                    label: 'COD Amount',
                                    value: 'Rs. ${widget.order.codCharge}',
                                    icon: Icons.payments_rounded,
                                    isPrice: true,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: theme.dividerColor,
                                ),
                                Expanded(
                                  child: _InfoItem(
                                    label: 'Delivery Charge',
                                    value: 'Rs. ${widget.order.deliveryCharge}',
                                    icon: Icons.local_shipping_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Package Description
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _InfoItem(
                              label: 'Package',
                              value: widget.order.description,
                              icon: Icons.inventory_2_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ActionButton(
                            icon: Icons.call_rounded,
                            label: 'Call',
                            onTap: _makePhoneCall,
                          ),
                          _ActionButton(
                            icon: Icons.map_rounded,
                            label: 'Track',
                            onTap: _openMaps,
                          ),
                          _ActionButton(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            onTap: _shareOrder,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  final Animation<double>? pulseAnimation;

  const _StatusBadge({
    required this.status,
    required this.color,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
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
              fontSize: 11,
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

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPrice;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              color: isPrice ? Colors.green : theme.textTheme.bodyMedium?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
