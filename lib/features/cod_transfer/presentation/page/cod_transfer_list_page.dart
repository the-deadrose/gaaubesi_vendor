import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/entity/cod_transfer_entity.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_bloc.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_event.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_state.dart';

@RoutePage()
class CodTransferListScreen extends StatefulWidget {
  const CodTransferListScreen({super.key});

  @override
  State<CodTransferListScreen> createState() => _CodTransferListScreenState();
}

class _CodTransferListScreenState extends State<CodTransferListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _isFetchingMore = false;
  late AnimationController _shimmerController;

  final List<CodTransferList> _items = [];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: false);
    _fetchInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchInitial() {
    context.read<CodTransferBloc>().add(
      FetchCodTransferList(page: _page.toString()),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 120 &&
        !_isFetchingMore &&
        _items.isNotEmpty) {
      _isFetchingMore = true;
      _page++;

      context.read<CodTransferBloc>().add(
        FetchCodTransferList(page: _page.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('COD Transfers'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<CodTransferBloc, CodTransferState>(
        listener: (context, state) {
          if (state is CodTransferListLoaded) {
            _items
              ..clear()
              ..addAll(state.codTransferList);
            _isFetchingMore = false;
          }

          if (state is CodTransferListPaginated) {
            _items.addAll(state.codTransferList);
            _isFetchingMore = false;
          }

          if (state is CodTransferListError ||
              state is CodTransferListPaginatingError) {
            _isFetchingMore = false;
          }
        },
        builder: (context, state) {
          if (state is CodTransferListLoading && _items.isEmpty) {
            return _buildLoadingState();
          }

          if (state is CodTransferListError && _items.isEmpty) {
            return _buildErrorState(state.message);
          }

          if ((state is CodTransferListLoaded && _items.isEmpty) ||
              (state is CodTransferListPaginated && _items.isEmpty)) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _page = 1;
              _items.clear();
              _fetchInitial();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _items.length + 1,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  if (state is CodTransferListPaginating && _items.isNotEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (_items.isNotEmpty &&
                      state is! CodTransferListPaginating) {
                    return _buildEndOfListMessage();
                  }

                  return const SizedBox.shrink();
                }

                return CodTransferCard(item: _items[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) {
        return ShimmerCodTransferCard(shimmerController: _shimmerController);
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchInitial,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        _page = 1;
        _items.clear();
        _fetchInitial();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No COD Transfers Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are no COD transfer records available at the moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchInitial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfListMessage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 16),
          Text(
            _items.length > 10
                ? "You've reached the end of the list"
                : "No more transfers to load",
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          if (_items.length > 10)
            Text(
              '${_items.length} transfers loaded',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CodTransferCard extends StatelessWidget {
  final CodTransferList item;

  const CodTransferCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                Text(
                  item.amount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildDetailRow('Payment ID', item.paymentId, context),
            _buildDetailRow('Receiver', item.receiver, context),
            _buildDetailRow(
              'Orders Count',
              item.orderCount.toString(),
              context,
            ),
            _buildDetailRow('Collection Mode', item.collectionMode, context),
            _buildDetailRow(
              'Transferred On',
              item.transferedOnFormatted,
              context,
            ),

            const SizedBox(height: 12),

            /// ORDER IDS
            if (item.orderIds.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Order IDs',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.orderIds.map((id) {
                  return Chip(
                    label: Text(
                      id.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            const Divider(),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Medium',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.transactionMediumName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerCodTransferCard extends StatelessWidget {
  final AnimationController shimmerController;

  const ShimmerCodTransferCard({super.key, required this.shimmerController});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomShimmer(
                    controller: shimmerController,
                    child: Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  CustomShimmer(
                    controller: shimmerController,
                    child: Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomShimmer(
                        controller: shimmerController,
                        child: Container(
                          width: 80 + (index * 10),
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      CustomShimmer(
                        controller: shimmerController,
                        child: Container(
                          width: 60 + (index * 5),
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Divider(),
              const SizedBox(height: 8),
              CustomShimmer(
                controller: shimmerController,
                child: Container(
                  width: 80,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(
                  4,
                  (index) => CustomShimmer(
                    controller: shimmerController,
                    child: Container(
                      width: 40 + (index * 10),
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Divider(),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomShimmer(
                    controller: shimmerController,
                    child: Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  CustomShimmer(
                    controller: shimmerController,
                    child: Container(
                      width: 60,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomShimmer extends StatefulWidget {
  final Widget child;
  final AnimationController controller;
  final Color baseColor;
  final Color highlightColor;
  final double shimmerWidth;

  const CustomShimmer({
    super.key,
    required this.child,
    required this.controller,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.shimmerWidth = 100.0,
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return ClipRect(
          child: CustomPaint(
            painter: _ShimmerPainter(
              animationValue: widget.controller.value,
              baseColor: widget.baseColor,
              highlightColor: widget.highlightColor,
              shimmerWidth: widget.shimmerWidth,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;
  final Color highlightColor;
  final double shimmerWidth;

  _ShimmerPainter({
    required this.animationValue,
    required this.baseColor,
    required this.highlightColor,
    required this.shimmerWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);
    final double shimmerStart = size.width * animationValue - shimmerWidth;
    final double shimmerEnd = size.width * animationValue;
    final gradient = LinearGradient(
      colors: [highlightColor, baseColor, highlightColor],
      stops: const [0.0, 0.5, 1.0],
    );

    final shimmerPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTRB(shimmerStart, 0, shimmerEnd, size.height),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRect(
      Rect.fromLTRB(shimmerStart, 0, shimmerEnd, size.height),
      shimmerPaint,
    );
    final glowPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawRect(
      Rect.fromLTRB(shimmerStart - 20, 0, shimmerEnd + 20, size.height),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        baseColor != oldDelegate.baseColor ||
        highlightColor != oldDelegate.highlightColor ||
        shimmerWidth != oldDelegate.shimmerWidth;
  }
}
