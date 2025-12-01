import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/delivered_order_card.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_card_shimmer.dart';

@RoutePage()
class DeliveredOrdersPage extends StatelessWidget {
  const DeliveredOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DeliveredOrderBloc>()..add(const DeliveredOrderLoadRequested()),
      child: const _DeliveredOrdersView(),
    );
  }
}

class _DeliveredOrdersView extends StatefulWidget {
  const _DeliveredOrdersView();

  @override
  State<_DeliveredOrdersView> createState() => _DeliveredOrdersViewState();
}

class _DeliveredOrdersViewState extends State<_DeliveredOrdersView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context
          .read<DeliveredOrderBloc>()
          .add(const DeliveredOrderLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: Text(
          'Delivered Orders',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.green,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green,
                Colors.green.shade700,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<DeliveredOrderBloc>()
              .add(const DeliveredOrderRefreshRequested());
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Stats Section
            SliverToBoxAdapter(
              child: BlocBuilder<DeliveredOrderBloc, DeliveredOrderState>(
                builder: (context, state) {
                  if (state is DeliveredOrderLoaded ||
                      state is DeliveredOrderLoadingMore) {
                    final totalCount = state is DeliveredOrderLoaded
                        ? state.totalCount
                        : (state as DeliveredOrderLoadingMore).totalCount;
                    final totalPages = state is DeliveredOrderLoaded
                        ? state.totalPages
                        : (state as DeliveredOrderLoadingMore).totalPages;
                    final currentOrders = state is DeliveredOrderLoaded
                        ? state.orders.length
                        : (state as DeliveredOrderLoadingMore).orders.length;

                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            icon: Icons.check_circle,
                            label: 'Total Delivered',
                            value: totalCount.toString(),
                            color: Colors.green,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.green.withOpacity(0.2),
                          ),
                          _buildStatItem(
                            context,
                            icon: Icons.pages,
                            label: 'Pages',
                            value: totalPages.toString(),
                            color: Colors.blue,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.green.withOpacity(0.2),
                          ),
                          _buildStatItem(
                            context,
                            icon: Icons.visibility,
                            label: 'Showing',
                            value: currentOrders.toString(),
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Orders List
            const _DeliveredOrderListSliver(),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _DeliveredOrderListSliver extends StatelessWidget {
  const _DeliveredOrderListSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveredOrderBloc, DeliveredOrderState>(
      builder: (context, state) {
        if (state is DeliveredOrderLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OrderCardShimmer(),
              ),
              childCount: 5,
            ),
          );
        }

        if (state is DeliveredOrderError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Orders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<DeliveredOrderBloc>()
                          .add(const DeliveredOrderLoadRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DeliveredOrderLoaded ||
            state is DeliveredOrderLoadingMore) {
          final orders = state is DeliveredOrderLoaded
              ? state.orders
              : (state as DeliveredOrderLoadingMore).orders;

          if (orders.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Delivered Orders',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You don\'t have any delivered orders yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < orders.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DeliveredOrderCard(
                      order: orders[index],
                      onTap: () {
                        // TODO: Navigate to order detail if needed
                      },
                    ),
                  );
                } else if (state is DeliveredOrderLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: OrderCardShimmer(),
                  );
                }
                return null;
              },
              childCount: orders.length +
                  (state is DeliveredOrderLoadingMore ? 1 : 0),
            ),
          );
        }

        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
