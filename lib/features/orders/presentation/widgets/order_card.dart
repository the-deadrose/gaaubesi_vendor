import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';

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
      duration: const Duration(milliseconds: 1600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
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

  String get _initials {
    final name = widget.order.receiverName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  double? _parseAmount(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  String _formatNpr(String raw) {
    final parsed = _parseAmount(raw);
    if (parsed == null) return raw;
    final whole = parsed.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return 'NPR $buffer';
  }

  @override
  Widget build(BuildContext context) {
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
            scale: _isPressed ? 0.99 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.disabledGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackBean.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildRoute(),
            const Divider(
              height: 1,
              color: AppTheme.disabledGray,
              thickness: 1,
            ),
            _buildReceiver(),
            const Divider(
              height: 1,
              color: AppTheme.disabledGray,
              thickness: 1,
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.order.orderId}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.marianBlue,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
                if (widget.order.deliveredDate.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.order.deliveredDate,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.powerBlue,
                      letterSpacing: -0.05,
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildStatusChip(),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.order.lastDeliveryStatus,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _accentColor,
              letterSpacing: -0.05,
              height: 1.1,
            ),
          ),
        ],
      ),
    );

    if (_isInTransit) {
      chip = ScaleTransition(scale: _pulseAnimation, child: chip);
    }
    return chip;
  }

  Widget _buildRoute() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      child: Row(
        children: [
          Expanded(child: _routeEndpoint('FROM', widget.order.source, false)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.marianBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 12,
                color: AppTheme.marianBlue,
              ),
            ),
          ),
          Expanded(child: _routeEndpoint('TO', widget.order.destination, true)),
        ],
      ),
    );
  }

  Widget _routeEndpoint(String label, String value, bool alignEnd) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.powerBlue,
            letterSpacing: 0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          softWrap: true,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.blackBean,
            letterSpacing: -0.15,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiver() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.marianBlue.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.marianBlue.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.marianBlue,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.receiverName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.blackBean,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.order.receiverNumber,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.darkGray,
                    letterSpacing: -0.05,
                    height: 1.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppTheme.powerBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.order.receiverAddress,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.darkGray,
                          letterSpacing: -0.05,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final codAmount = _parseAmount(widget.order.codCharge);
    final hasCod = codAmount != null && codAmount > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasCod ? 'COD AMOUNT' : 'DELIVERY',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.powerBlue,
                    letterSpacing: 0.6,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatNpr(
                    hasCod
                        ? widget.order.codCharge
                        : widget.order.deliveryCharge,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: hasCod ? AppTheme.successGreen : AppTheme.blackBean,
                    letterSpacing: -0.3,
                    height: 1.1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          _FooterAction(
            icon: Icons.call_rounded,
            tooltip: 'Call receiver',
            onTap: () => makePhoneCall(widget.order.receiverNumber),
          ),
          _FooterAction(
            icon: Icons.ios_share_rounded,
            tooltip: 'Share',
            onTap: () => shareOrder(widget.order.orderIdWithStatus),
          ),
        ],
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _FooterAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.marianBlue.withValues(alpha: 0.12),
        highlightColor: AppTheme.marianBlue.withValues(alpha: 0.06),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 16, color: AppTheme.marianBlue),
          ),
        ),
      ),
    );
  }
}
