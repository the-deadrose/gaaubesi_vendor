import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/edit_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/widgets/add_comment_dialog.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/widgets/edit_order_dialog.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/widgets/edit_package_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with OrderCardActionsMixin {
  bool _isMessagesExpanded = true;
  bool _isCommentsExpanded = true;
  bool _isStatusUpdatesExpanded = true;
  bool _isDeliveryAddressExpanded = false;
  bool _isDeliveryInstructionExpanded = false;
  final TextEditingController _newCommentController = TextEditingController();
  String _selectedCommentType = 'Information';

  @override
  void initState() {
    super.initState();
    context.read<OrderDetailBloc>().add(
      OrderDetailRequested(orderId: widget.orderId),
    );
  }

  @override
  void dispose() {
    _newCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF6F7FB),
      body: BlocConsumer<OrderDetailBloc, OrderDetailState>(
        listenWhen: (prev, curr) =>
            curr is OrderEditSuccess || curr is OrderEditFailure,
        listener: (context, state) {
          if (state is OrderEditSuccess) {
            _showResultSnack(
              message: 'Order updated successfully',
              icon: Icons.check_circle_rounded,
              color: theme.extra.success,
            );
          } else if (state is OrderEditFailure) {
            _showResultSnack(
              message: state.message.isEmpty
                  ? 'Could not update the order'
                  : state.message,
              icon: Icons.error_outline_rounded,
              color: theme.colorScheme.error,
            );
          }
        },
        buildWhen: (prev, curr) =>
            curr is OrderDetailLoading ||
            curr is OrderDetailError ||
            curr is OrderDetailLoaded,
        builder: (context, state) {
          if (state is OrderDetailLoading) {
            return _buildLoadingScaffold(theme);
          }

          if (state is OrderDetailError) {
            return _buildErrorScaffold(context, theme, state.message);
          }

          if (state is OrderDetailLoaded) {
            return _buildLoadedScaffold(context, state.order);
          }

          return _buildLoadingScaffold(theme);
        },
      ),
    );
  }

  void _showResultSnack({
    required String message,
    required IconData icon,
    required Color color,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // SCAFFOLDS
  // ───────────────────────────────────────────────

  Widget _buildLoadingScaffold(ThemeData theme) {
    return Column(
      children: [
        _buildStaticAppBar(title: 'Order Details'),
        Expanded(
          child: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorScaffold(
    BuildContext context,
    ThemeData theme,
    String message,
  ) {
    return Column(
      children: [
        _buildStaticAppBar(title: 'Order Details'),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 42,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Couldn\'t load this order',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<OrderDetailBloc>().add(
                        OrderDetailRequested(orderId: widget.orderId),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedScaffold(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderDetailBloc>().add(
          OrderDetailRefreshRequested(orderId: order.orderId),
        );
      },
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, order),
          SliverToBoxAdapter(child: _buildQuickStats(context, order)),
          SliverToBoxAdapter(child: _buildReceiverCard(context, order)),
          SliverToBoxAdapter(child: _buildAdditionalInfoCard(context, order)),
          SliverToBoxAdapter(child: _buildStatusTimelineCard(context, order)),
          SliverToBoxAdapter(child: _buildCommentsCard(context, order)),
          SliverToBoxAdapter(child: _buildMessagesCard(context, order)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildStaticAppBar({required String title}) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      title: Text(title),
      centerTitle: false,
      elevation: 0,
    );
  }

  // ───────────────────────────────────────────────
  // PINNED SLIVER APP BAR — hero with embedded QR
  // ───────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    const double expandedHeight = 350;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 0,
      scrolledUnderElevation: 6,
      surfaceTintColor: Colors.transparent,
      shadowColor: primary.withValues(alpha: 0.4),
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(Icons.arrow_back_rounded, color: onPrimary),
        tooltip: 'Back',
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Flexible(
            child: Text(
              'Order ${order.orderId}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // const SizedBox(width: 8),
          // _collapsedStatusDot(order.lastDeliveryStatus, theme),
        ],
      ),
      actions: [
        if (order.getIsEditable)
          IconButton(
            tooltip: 'Edit order',
            icon: Icon(Icons.edit_outlined, color: onPrimary),
            onPressed: () => _openEditDialog(order),
          ),
        IconButton(
          tooltip: 'Copy tracking ID',
          icon: Icon(Icons.copy_rounded, color: onPrimary),
          onPressed: () => _copyToClipboard(
            order.trackId.isEmpty ? order.orderId.toString() : order.trackId,
            'Tracking ID copied',
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.biggest.height;
          final safeTop = MediaQuery.paddingOf(context).top;
          final collapsed = kToolbarHeight + safeTop;
          final range = (expandedHeight - collapsed).clamp(
            1.0,
            double.infinity,
          );
          final t = ((currentHeight - collapsed) / range).clamp(0.0, 1.0);

          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary,
                        Color.lerp(primary, Colors.black, 0.25) ?? primary,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: collapsed + 4,
                  left: 16,
                  right: 16,
                  child: IgnorePointer(
                    ignoring: t < 0.25,
                    child: Opacity(
                      opacity: t,
                      child: _buildHeroBody(order, theme, onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBody(
    OrderDetailEntity order,
    ThemeData theme,
    Color onPrimary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusPill(order.lastDeliveryStatus, theme),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _routeColumn(
                      label: 'FROM',
                      value: order.sourceBranch,
                      code: order.sourceBranchCode,
                      align: CrossAxisAlignment.start,
                      onPrimary: onPrimary,
                      theme: theme,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_shipping_outlined,
                        color: onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _routeColumn(
                      label: 'TO',
                      value: order.destinationBranch,
                      code: order.destinationBranchCode,
                      align: CrossAxisAlignment.end,
                      onPrimary: onPrimary,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: onPrimary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      order.createdOnFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onPrimary.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildHeroQrStrip(order, theme, onPrimary),
      ],
    );
  }

  Widget _buildHeroQrStrip(
    OrderDetailEntity order,
    ThemeData theme,
    Color onPrimary,
  ) {
    final trackingLabel = order.trackId.isEmpty
        ? order.orderId.toString()
        : order.trackId;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showQrDialog(order),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEFF1F6)),
                ),
                child: _buildQrImage(order.qrCode, size: 56),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TRACKING ID',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trackingLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to enlarge & scan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.open_in_full_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _collapsedStatusDot(String status, ThemeData theme) {
    final (_, fg, _) = _statusStyle(status, theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: fg == Colors.white
                  ? Colors.white
                  : Color.lerp(fg, Colors.white, 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: fg.withValues(alpha: 0.6), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10.5,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeColumn({
    required String label,
    required String value,
    required String code,
    required CrossAxisAlignment align,
    required Color onPrimary,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: onPrimary.withValues(alpha: 0.65),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: align == CrossAxisAlignment.end
              ? TextAlign.end
              : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: onPrimary,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        if (code.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            code,
            style: theme.textTheme.bodySmall?.copyWith(
              color: onPrimary.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusPill(String status, ThemeData theme) {
    final (bg, fg, icon) = _statusStyle(status, theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _statusStyle(String status, ThemeData theme) {
    final s = status.toLowerCase();
    final extra = theme.extra;
    if (s.contains('delivered')) {
      return (
        extra.success.withValues(alpha: 0.18),
        extra.success,
        Icons.check_circle_rounded,
      );
    }
    if (s.contains('return') || s.contains('rtv')) {
      return (
        theme.colorScheme.error.withValues(alpha: 0.18),
        theme.colorScheme.error,
        Icons.assignment_return_rounded,
      );
    }
    if (s.contains('redirect')) {
      return (
        extra.warning.withValues(alpha: 0.22),
        extra.warning,
        Icons.alt_route_rounded,
      );
    }
    if (s.contains('hold')) {
      return (
        extra.warning.withValues(alpha: 0.22),
        extra.warning,
        Icons.pause_circle_outline_rounded,
      );
    }
    if (s.contains('transit') || s.contains('dispatch')) {
      return (
        extra.info.withValues(alpha: 0.2),
        extra.info,
        Icons.local_shipping_rounded,
      );
    }
    return (
      Colors.white.withValues(alpha: 0.22),
      Colors.white,
      Icons.radio_button_checked_rounded,
    );
  }

  // ───────────────────────────────────────────────
  // QUICK STATS
  // ───────────────────────────────────────────────
  Widget _buildQuickStats(BuildContext context, OrderDetailEntity order) {
    return Transform.translate(
      offset: const Offset(0, 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.payments_outlined,
                label: 'COD',
                value: 'Rs. ${order.codCharge}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                icon: Icons.local_shipping_outlined,
                label: 'Delivery',
                value: 'Rs. ${order.deliveryCharge}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                icon: Icons.scale_outlined,
                label: 'Weight',
                value: order.weight.isEmpty ? '-' : '${order.weight} kg',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFF1F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // RECEIVER CARD
  // ───────────────────────────────────────────────
  Widget _buildReceiverCard(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              icon: Icons.person_outline_rounded,
              title: 'Receiver',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(order.receiverName),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.receiverName.isEmpty
                            ? 'Unknown'
                            : order.receiverName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.pickupType.isEmpty
                            ? 'Receiver'
                            : order.pickupType,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.55,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _infoRow(
              icon: Icons.call_outlined,
              label: 'Phone',
              value: order.receiverNumber,
              trailing: order.receiverNumber.isEmpty
                  ? null
                  : _ghostAction(
                      icon: Icons.phone_in_talk_rounded,
                      tooltip: 'Call',
                      onTap: () => _launchTel(order.receiverNumber),
                    ),
            ),
            if (order.altReceiverNumber.isNotEmpty) ...[
              const SizedBox(height: 12),
              _infoRow(
                icon: Icons.call_outlined,
                label: 'Alternate phone',
                value: order.altReceiverNumber,
                trailing: _ghostAction(
                  icon: Icons.phone_in_talk_rounded,
                  tooltip: 'Call',
                  onTap: () => _launchTel(order.altReceiverNumber),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _infoRow(
              icon: Icons.place_outlined,
              label: 'Delivery address',
              value: order.receiverAddress.isEmpty
                  ? '-'
                  : order.receiverAddress,
              multiline: true,
              trailing: order.receiverAddress.isEmpty
                  ? null
                  : _ghostAction(
                      icon: Icons.copy_rounded,
                      tooltip: 'Copy',
                      onTap: () => _copyToClipboard(
                        order.receiverAddress,
                        'Address copied',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // ADDITIONAL INFO
  // ───────────────────────────────────────────────
  Widget _buildAdditionalInfoCard(
    BuildContext context,
    OrderDetailEntity order,
  ) {
    final packageAccess = order.packageAccess.isEmpty
        ? 'None'
        : order.packageAccess;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _sectionHeader(
                    icon: Icons.inventory_2_outlined,
                    title: 'Package Details',
                  ),
                ),
                if (order.getIsEditable)
                  _ghostAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit package',
                    onTap: () => _openEditPackageDialog(order),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _kvRow('Tracking code', order.orderId.toString()),
            _kvDivider(),
            _kvRow('Package access', packageAccess),
            _kvDivider(),
            _kvRow(
              'Delivery instruction',
              order.deliveryInstruction.isEmpty
                  ? '-'
                  : order.deliveryInstruction,
            ),
            _kvDivider(),
            _kvRow(
              'Vendor ref ID',
              order.vendorReferenceId.isEmpty
                  ? 'None'
                  : order.vendorReferenceId,
            ),
            _kvDivider(),
            _kvRow(
              'Description',
              order.orderDescription.isEmpty ? '-' : order.orderDescription,
            ),
            _kvDivider(),
            _kvRow(
              'Payment',
              order.paymentType.isEmpty ? '-' : order.paymentType,
            ),
            _kvDivider(),
            _kvRow(
              'Created by',
              order.vendorName.isEmpty ? '-' : order.vendorName,
            ),
            if (order.deliveredDateFormatted.isNotEmpty) ...[
              _kvDivider(),
              _kvRow('Delivered on', order.deliveredDateFormatted),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kvRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvDivider() => Container(height: 1, color: const Color(0xFFF0F2F6));

  Widget _buildQrImage(String qrBase64, {double size = 180}) {
    final fallback = SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(Icons.qr_code_2, size: size * 0.55, color: Colors.grey),
      ),
    );
    if (qrBase64.isEmpty) return fallback;
    try {
      return Image.memory(
        base64Decode(qrBase64),
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      );
    } catch (_) {
      return fallback;
    }
  }

  void _showQrDialog(OrderDetailEntity order) {
    final theme = Theme.of(context);
    final trackingLabel = order.trackId.isEmpty
        ? order.orderId.toString()
        : order.trackId;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext).shortestSide * 0.72;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderId}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Tracking: $trackingLabel',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.55,
                              ),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEFF1F6)),
                  ),
                  child: _buildQrImage(order.qrCode, size: size),
                ),
                const SizedBox(height: 14),
                Text(
                  'Present this code at the pickup point',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // STATUS TIMELINE
  // ───────────────────────────────────────────────
  Widget _buildStatusTimelineCard(
    BuildContext context,
    OrderDetailEntity order,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _collapsibleHeader(
              icon: Icons.timeline_rounded,
              title: 'Status Updates',
              expanded: _isStatusUpdatesExpanded,
              onTap: () => setState(
                () => _isStatusUpdatesExpanded = !_isStatusUpdatesExpanded,
              ),
            ),
            if (_isStatusUpdatesExpanded) ...[
              const SizedBox(height: 16),
              _timelineItem(
                theme: theme,
                isLast: true,
                isCurrent: true,
                title: order.lastDeliveryStatus,
                subtitle: 'Updated by you',
                trailing: order.createdOnFormatted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timelineItem({
    required ThemeData theme,
    required bool isLast,
    required bool isCurrent,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    final primary = theme.colorScheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isCurrent ? primary : primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: primary.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        trailing,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // COMMENTS
  // ───────────────────────────────────────────────
  Widget _buildCommentsCard(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);
    final comments = order.comments ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _collapsibleHeader(
                    icon: Icons.mode_comment_outlined,
                    title: 'Comments',
                    count: comments.length,
                    expanded: _isCommentsExpanded,
                    onTap: () => setState(
                      () => _isCommentsExpanded = !_isCommentsExpanded,
                    ),
                  ),
                ),
                _primaryPillButton(
                  icon: Icons.add_rounded,
                  label: 'New',
                  onTap: () => _openAddCommentDialog(),
                ),
              ],
            ),
            if (_isCommentsExpanded) ...[
              const SizedBox(height: 14),
              if (comments.isEmpty)
                _emptyState(
                  icon: Icons.forum_outlined,
                  message: 'No comments yet',
                  hint: 'Tap New to add the first one.',
                )
              else
                ...List.generate(comments.length, (index) {
                  final c = comments[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == comments.length - 1 ? 0 : 12,
                    ),
                    child: _commentTile(c, theme),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _commentTile(CommentsEntity comment, ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final isImportant = comment.isImportant;
    final accent = isImportant ? theme.colorScheme.error : primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isImportant
            ? theme.colorScheme.error.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isImportant
              ? theme.colorScheme.error.withValues(alpha: 0.2)
              : const Color(0xFFEFF1F6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(comment.addedByName),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.addedByName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      comment.createdOnFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              _softChip(label: comment.commentTypeDisplay, color: accent),
              if (isImportant) ...[
                const SizedBox(width: 6),
                _softChip(
                  label: 'Important',
                  icon: Icons.priority_high_rounded,
                  color: theme.colorScheme.error,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.comments,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          if (comment.canReply) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: _ghostButton(
                icon: Icons.reply_rounded,
                label: 'Reply',
                onTap: () => _openAddCommentDialog(replyTo: comment),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // MESSAGES
  // ───────────────────────────────────────────────
  Widget _buildMessagesCard(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);
    final messages = order.messages ?? [];
    if (messages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _collapsibleHeader(
              icon: Icons.campaign_outlined,
              title: 'Messages',
              count: messages.length,
              expanded: _isMessagesExpanded,
              onTap: () =>
                  setState(() => _isMessagesExpanded = !_isMessagesExpanded),
            ),
            if (_isMessagesExpanded) ...[
              const SizedBox(height: 14),
              ...List.generate(messages.length, (index) {
                final m = messages[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == messages.length - 1 ? 0 : 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEFF1F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _softChip(
                              label: m.messageType,
                              color: theme.colorScheme.primary,
                            ),
                            const Spacer(),
                            Text(
                              m.sentOnFormatted,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m.messageText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'From ${m.sentByName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // REUSABLE PRIMITIVES
  // ───────────────────────────────────────────────
  Widget _sectionCard({required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFF1F6)),
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _collapsibleHeader({
    required IconData icon,
    required String title,
    int? count,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool multiline = false,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: multiline ? 4 : 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }

  Widget _softChip({
    required String label,
    IconData? icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 10 : 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ghostAction({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    final btn = Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  Widget _ghostButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryPillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String message,
    required String hint,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // HELPERS
  // ───────────────────────────────────────────────
  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Future<void> _launchTel(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _copyToClipboard(String text, String confirm) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirm),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _dispatchOrderEdit(int orderId, Map<String, dynamic> data) {
    context.read<OrderDetailBloc>().add(
      OrderEditRequested(
        orderId: orderId,
        request: OrderEditEntity(
          branch: data['branch'] as int,
          destinationBranch: data['destinationBranch'] as int,
          weight: data['weight'] as double,
          codCharge: data['codCharge'] as int,
          packageAccess: data['packageAccess'] as String,
          packageType: data['packageType'] as String,
          remarks: data['remarks'] as String,
          receiverName: data['receiverName'] as String,
          receiverPhoneNumber: data['receiverPhoneNumber'] as String,
          pickupType: data['pickupType'] as String,
          altReceiverPhoneNumber: data['altReceiverPhoneNumber'] as String,
          receiverFullAddress: data['receiverFullAddress'] as String,
        ),
      ),
    );
  }

  void _openEditDialog(OrderDetailEntity order) {
    EditOrderDialog.show(
      context,
      order: order,
      onUpdate: (data) => _dispatchOrderEdit(order.orderId, data),
    );
  }

  void _openEditPackageDialog(OrderDetailEntity order) {
    EditPackageDialog.show(
      context,
      order: order,
      onUpdate: (data) => _dispatchOrderEdit(order.orderId, data),
    );
  }

  void _openAddCommentDialog({CommentsEntity? replyTo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddCommentDialog(
        orderId: widget.orderId,
        commentToReply: replyTo,
        commentController: _newCommentController,
        selectedCommentType: _selectedCommentType,
        onCommentTypeChanged: (type) => _selectedCommentType = type,
      ),
    );
  }
}
