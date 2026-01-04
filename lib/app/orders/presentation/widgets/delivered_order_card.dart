import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/delivered_order_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveredOrderCard extends StatefulWidget {
  final DeliveredOrderEntity order;
  final VoidCallback? onTap;

  const DeliveredOrderCard({super.key, required this.order, this.onTap});

  @override
  State<DeliveredOrderCard> createState() => _DeliveredOrderCardState();
}

class _DeliveredOrderCardState extends State<DeliveredOrderCard> {
  bool _isPressed = false;

  void _makePhoneCall() async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse('tel:${widget.order.receiverNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyOrderId() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: widget.order.orderId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ID ${widget.order.orderId} copied!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
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
                // Header Section with Success Green
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Order ID
                      Expanded(
                        child: GestureDetector(
                          onTap: _copyOrderId,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.order.orderId,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Delivered',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // COD Charge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'NPR ${widget.order.codCharge}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Receiver Information
                      _buildInfoRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'Receiver',
                        value: widget.order.receiverName,
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      
                      // Phone Number with Action
                      _buildInfoRow(
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: widget.order.receiverNumber,
                        iconColor: Colors.orange,
                        trailing: IconButton(
                          icon: const Icon(Icons.call, size: 20),
                          onPressed: _makePhoneCall,
                          tooltip: 'Call',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Destination
                      _buildInfoRow(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Destination',
                        value: widget.order.destination,
                        iconColor: Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      
                      // Delivery Charge
                      _buildInfoRow(
                        context,
                        icon: Icons.local_shipping_outlined,
                        label: 'Delivery Charge',
                        value: 'NPR ${widget.order.deliveryCharge}',
                        iconColor: Colors.teal,
                      ),
                      
                      const Divider(height: 24),
                      
                      // Dates Section
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateChip(
                              context,
                              icon: Icons.event_available,
                              label: 'Delivered',
                              date: widget.order.deliveredDate,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDateChip(
                              context,
                              icon: Icons.event,
                              label: 'Created',
                              date: widget.order.createdOn,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildDateChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String date,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
