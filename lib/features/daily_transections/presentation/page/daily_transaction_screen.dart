import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/entity/daily_transections_entity.dart';
import 'package:gaaubesi_vendor/features/daily_transections/presentation/bloc/daily_transaction_bloc.dart';
import 'package:gaaubesi_vendor/features/daily_transections/presentation/bloc/daily_transaction_event.dart';
import 'package:gaaubesi_vendor/features/daily_transections/presentation/bloc/daily_transaction_state.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DailyTransactionScreen extends StatefulWidget {
  final String? date;

  const DailyTransactionScreen({super.key, @QueryParam() this.date});

  @override
  State<DailyTransactionScreen> createState() => _DailyTransactionScreenState();
}

class _DailyTransactionScreenState extends State<DailyTransactionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: false);
    _fetchTransactions();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _fetchTransactions() {
    context.read<DailyTransactionBloc>().add(
      FetchDailyTransactionEvent(date: widget.date ?? ''),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return DateFormat('dd MMM yyyy').format(DateTime.now());
    }
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Daily Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<DailyTransactionBloc, DailyTransactionState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is DailyTransactionListLoading) {
            return _buildLoadingState();
          }

          if (state is DailyTransactionListError) {
            return _buildErrorState(state.message);
          }

          if (state is DailyTransactionListLoaded) {
            final dailyList = state.dailyTransections;

            // Handle empty list properly
            if (dailyList.isEmpty) {
              return _buildEmptyState();
            }

            final daily = dailyList.first;

            return RefreshIndicator(
              onRefresh: () async {
                _fetchTransactions();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(widget.date),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${daily.deliveredOrdersCount + daily.returnedOrdersCount} Orders',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Summary Cards
                  SliverToBoxAdapter(
                    child: _buildSummarySection(context, daily),
                  ),

                  // Delivered Orders
                  SliverToBoxAdapter(
                    child: _buildOrdersSection(
                      context,
                      title: 'Delivered Orders',
                      orders: daily.deliveredOrders,
                      count: daily.deliveredOrdersCount,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),

                  // Returned Orders
                  SliverToBoxAdapter(
                    child: _buildOrdersSection(
                      context,
                      title: 'Returned Orders',
                      orders: daily.returnedOrders,
                      count: daily.returnedOrdersCount,
                      icon: Icons.undo,
                      color: Colors.orange,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header Shimmer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomShimmer(
                            controller: _shimmerController,
                            child: Container(
                              width: 80,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      CustomShimmer(
                        controller: _shimmerController,
                        child: Container(
                          width: 60,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Summary Section Shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmer(
                  controller: _shimmerController,
                  child: Container(
                    width: 120,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CustomShimmer(
                            controller: _shimmerController,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          title: CustomShimmer(
                            controller: _shimmerController,
                            child: Container(
                              width: double.infinity,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          trailing: CustomShimmer(
                            controller: _shimmerController,
                            child: Container(
                              width: 80,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Delivered Orders Shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomShimmer(
                      controller: _shimmerController,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomShimmer(
                          controller: _shimmerController,
                          child: Container(
                            width: 140,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomShimmer(
                          controller: _shimmerController,
                          child: Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                                controller: _shimmerController,
                                child: Container(
                                  width: 100,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              CustomShimmer(
                                controller: _shimmerController,
                                child: Container(
                                  width: 60,
                                  height: 20,
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
                            3,
                            (detailIndex) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  CustomShimmer(
                                    controller: _shimmerController,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomShimmer(
                                      controller: _shimmerController,
                                      child: Container(
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  CustomShimmer(
                                    controller: _shimmerController,
                                    child: Container(
                                      width: 60,
                                      height: 16,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Returned Orders Shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomShimmer(
                      controller: _shimmerController,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomShimmer(
                          controller: _shimmerController,
                          child: Container(
                            width: 140,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomShimmer(
                          controller: _shimmerController,
                          child: Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  2,
                  (index) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                                controller: _shimmerController,
                                child: Container(
                                  width: 100,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              CustomShimmer(
                                controller: _shimmerController,
                                child: Container(
                                  width: 60,
                                  height: 20,
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
                            3,
                            (detailIndex) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  CustomShimmer(
                                    controller: _shimmerController,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomShimmer(
                                      controller: _shimmerController,
                                      child: Container(
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  CustomShimmer(
                                    controller: _shimmerController,
                                    child: Container(
                                      width: 60,
                                      height: 16,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              onPressed: _fetchTransactions,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Transactions Found',
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
              'There are no transactions recorded for ${_formatDate(widget.date)}',
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
              onPressed: _fetchTransactions,
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
    );
  }

  Widget _buildSummarySection(BuildContext context, DailyTransections daily) {
    final summaryItems = [
      if (daily.codTransferTotal.isNotEmpty)
        _SummaryItem(
          title: 'COD Transfer',
          value: daily.codTransferTotal,
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
        ),
      if (daily.totalCodChargeDelivered.isNotEmpty)
        _SummaryItem(
          title: 'Total COD Delivered',
          value: daily.totalCodChargeDelivered,
          icon: Icons.delivery_dining,
          color: Colors.green,
        ),
      if (daily.totalDeliveryChargeDelivered.isNotEmpty)
        _SummaryItem(
          title: 'Total Delivery Delivered',
          value: daily.totalDeliveryChargeDelivered,
          icon: Icons.local_shipping,
          color: Colors.green,
        ),
      if (daily.totalCodChargeReturned.isNotEmpty)
        _SummaryItem(
          title: 'Total COD Returned',
          value: daily.totalCodChargeReturned,
          icon: Icons.keyboard_return,
          color: Colors.orange,
        ),
      if (daily.totalDeliveryChargeReturned.isNotEmpty)
        _SummaryItem(
          title: 'Total Delivery Returned',
          value: daily.totalDeliveryChargeReturned,
          icon: Icons.replay,
          color: Colors.orange,
        ),
    ];

    if (summaryItems.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ...summaryItems.map((item) => _buildSummaryRow(context, item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, _SummaryItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, size: 20, color: item.color),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        trailing: Text(
          item.value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersSection(
    BuildContext context, {
    required String title,
    required List<DailyOrder> orders,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    // Show empty message if no orders
    if (count == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '0 orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Text(
                  'No ${title.toLowerCase()} for this date',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '$count ${count == 1 ? 'order' : 'orders'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...orders.map((order) => _buildOrderCard(context, order, color)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    DailyOrder order,
    Color sectionColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: sectionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sectionColor == Colors.green ? 'Delivered' : 'Returned',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: sectionColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (order.codCharge.isNotEmpty)
              _buildOrderDetailRow(
                context,
                icon: Icons.monetization_on,
                label: 'COD Charge',
                value: order.codCharge,
                color: Colors.blue,
              ),
            if (order.deliveryCharge.isNotEmpty)
              _buildOrderDetailRow(
                context,
                icon: Icons.local_shipping,
                label: 'Delivery Charge',
                value: order.deliveryCharge,
                color: Colors.purple,
              ),
            if (order.deliveredDateFormatted.isNotEmpty)
              _buildOrderDetailRow(
                context,
                icon: Icons.access_time,
                label: sectionColor == Colors.green
                    ? 'Delivered On'
                    : 'Returned On',
                value: order.deliveredDateFormatted,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// Custom Shimmer Widget
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
    // Fill with base color
    final basePaint = Paint()..color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // Calculate shimmer position
    final double shimmerStart = size.width * animationValue - shimmerWidth;
    final double shimmerEnd = size.width * animationValue;

    // Create shimmer gradient
    final gradient = LinearGradient(
      colors: [
        highlightColor,
        baseColor,
        highlightColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final shimmerPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTRB(
          shimmerStart,
          0,
          shimmerEnd,
          size.height,
        ),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Draw shimmer
    canvas.drawRect(
      Rect.fromLTRB(
        shimmerStart,
        0,
        shimmerEnd,
        size.height,
      ),
      shimmerPaint,
    );

    // Draw additional glow effect
    final glowPaint = Paint()
      ..color = highlightColor.withValues(alpha:  0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawRect(
      Rect.fromLTRB(
        shimmerStart - 20,
        0,
        shimmerEnd + 20,
        size.height,
      ),
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