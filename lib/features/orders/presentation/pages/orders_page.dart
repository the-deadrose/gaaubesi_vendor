import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_state.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_card.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_card_shimmer.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_advanced_filters.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_search_delegate.dart';

@RoutePage()
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderBloc>()..add(const OrderLoadRequested()),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          // All Orders - stay on current page
          break;
        case 1:
          // Delivered Orders - navigate to delivered orders page
          context.router.push(const DeliveredOrdersRoute()).then((_) {
            // Reset tab to "All Orders" when coming back
            _tabController.index = 0;
          });
          break;
        case 2:
          // Possible Redirect Orders
          // TODO: Create and navigate to possible redirect orders page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Possible Redirect Orders - Coming Soon')),
          );
          _tabController.index = 0;
          break;
        case 3:
          // Returned Orders
          // TODO: Create and navigate to returned orders page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Returned Orders - Coming Soon')),
          );
          _tabController.index = 0;
          break;
        case 4:
          // RTV Orders
          // TODO: Create and navigate to RTV orders page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('RTV Orders - Coming Soon')),
          );
          _tabController.index = 0;
          break;
        case 5:
          // Warehouse Orders
          // TODO: Create and navigate to warehouse orders page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Warehouse Orders - Coming Soon')),
          );
          _tabController.index = 0;
          break;
      }
    }
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<OrderBloc>().add(const OrderLoadMoreRequested());
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
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            final scaffoldState = Scaffold.of(context);
            if (scaffoldState.hasDrawer) {
              scaffoldState.openDrawer();
            }
          },
        ),
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: [
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  final orders = state is OrderLoaded
                      ? state.orders
                      : (state is OrderLoadingMore
                            ? state.orders
                            : <OrderEntity>[]);
                  showSearch(
                    context: context,
                    delegate: OrderSearchDelegate(
                      allOrders: orders,
                      onSearchQueryChanged: (query) {},
                      onClearRecentSearches: () {},
                    ),
                  );
                },
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Delivered'),
            Tab(text: 'Possible Redirect'),
            Tab(text: 'Returned'),
            Tab(text: 'RTV'),
            Tab(text: 'Warehouse'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<OrderBloc>().add(const OrderRefreshRequested());
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  String? sourceBranch;
                  String? destinationBranch;
                  String? startDate;
                  String? endDate;
                  String? status;

                  if (state is OrderLoaded) {
                    sourceBranch = state.sourceBranch;
                    destinationBranch = state.destinationBranch;
                    startDate = state.startDate;
                    endDate = state.endDate;
                    status = state.currentStatus;
                  } else if (state is OrderLoadingMore) {
                    sourceBranch = state.sourceBranch;
                    destinationBranch = state.destinationBranch;
                    startDate = state.startDate;
                    endDate = state.endDate;
                    status = state.currentStatus;
                  }

                  return OrderAdvancedFilters(
                    selectedSourceBranch: sourceBranch,
                    selectedDestinationBranch: destinationBranch,
                    selectedStartDate: startDate,
                    selectedEndDate: endDate,
                    selectedStatus: status,
                    onFilterChanged:
                        ({
                          sourceBranch,
                          destinationBranch,
                          startDate,
                          endDate,
                          status,
                        }) {
                          context.read<OrderBloc>().add(
                            OrderAdvancedFilterChanged(
                              sourceBranch: sourceBranch,
                              destinationBranch: destinationBranch,
                              startDate: startDate,
                              endDate: endDate,
                              status: status,
                            ),
                          );
                        },
                  );
                },
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(top: 16)),
            const _OrderListSliver(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
}

class _OrderListSliver extends StatelessWidget {
  const _OrderListSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OrderCardShimmer(),
              ),
              childCount: 5,
            ),
          );
        } else if (state is OrderError) {
          return SliverToBoxAdapter(
            child: _ErrorView(
              message: state.message,
              onRetry: () {
                context.read<OrderBloc>().add(const OrderRefreshRequested());
              },
            ),
          );
        } else if (state is OrderLoaded || state is OrderLoadingMore) {
          final orders = state is OrderLoaded
              ? state.orders
              : (state as OrderLoadingMore).orders;

          if (orders.isEmpty) {
            return const SliverToBoxAdapter(child: _EmptyView());
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= orders.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }

              final order = orders[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: OrderCard(
                  order: order,
                  onTap: () {
                    // TODO: Navigate to order details
                  },
                ),
              );
            }, childCount: orders.length + (state is OrderLoadingMore ? 1 : 0)),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
