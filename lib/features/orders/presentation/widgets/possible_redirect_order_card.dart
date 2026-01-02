import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/possible_redirect_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/card_action_button.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/info_item.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/status_badge.dart';

class PossibleRedirectOrderCard extends StatefulWidget {
  final PossibleRedirectOrderEntity order;
  final VoidCallback? onTap;

  const PossibleRedirectOrderCard({super.key, required this.order, this.onTap});

  @override
  State<PossibleRedirectOrderCard> createState() =>
      _PossibleRedirectOrderCardState();
}

class _PossibleRedirectOrderCardState extends State<PossibleRedirectOrderCard>
    with OrderCardActionsMixin {
  bool _isPressed = false;
  static const _accentColor = Colors.orange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Hero(
      tag: 'redirect_order_${widget.order.orderId}_${widget.order.hashCode}',
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
                child: const Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: _accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${widget.order.orderId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Created: ${widget.order.createdOn}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const StatusBadge(status: 'Redirect', color: _accentColor),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildInfoContainer(
            theme,
            child: InfoItem(
              label: 'Destination',
              value: widget.order.destination,
              icon: Icons.location_on_rounded,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoContainer(
            theme,
            child: InfoItem(
              label: 'Receiver',
              value: widget.order.receiver,
              icon: Icons.person_rounded,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoContainer(
            theme,
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(ThemeData theme, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
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
            onTap: () => makePhoneCall(widget.order.receiver),
          ),
          CardActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () => shareOrder(widget.order.orderId.toString()),
          ),
        ],
      ),
    );
  }
}
