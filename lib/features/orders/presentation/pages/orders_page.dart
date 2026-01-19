import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/search_orders_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/all_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/delivered_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/possible_redirect_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/returned_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/rtv_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/stale_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/warehouse_order_screen.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_event.dart';
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

class _OrdersViewState extends State<_OrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FC),
      appBar: _buildAppBar(context, theme),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Orders
          BlocProvider(
            create: (context) =>
                getIt<OrderBloc>()..add(const OrderLoadRequested()),
            child: const AllOrdersTab(),
          ),
          // Delivered Orders
          BlocProvider(
            create: (context) =>
                getIt<DeliveredOrderBloc>()
                  ..add(const DeliveredOrderLoadRequested()),
            child: const DeliveredOrdersTab(),
          ),
          // Possible Redirect Orders
          BlocProvider(
            create: (context) =>
                getIt<PossibleRedirectOrderBloc>()
                  ..add(const PossibleRedirectOrderLoadRequested()),
            child: const PossibleRedirectOrdersTab(),
          ),
          // Returned Orders
          BlocProvider(
            create: (context) =>
                getIt<ReturnedOrderBloc>()
                  ..add(const ReturnedOrderLoadRequested()),
            child: const ReturnedOrdersTab(),
          ),
          // RTV Orders
          BlocProvider(
            create: (context) =>
                getIt<RtvOrderBloc>()..add(const RtvOrderLoadRequested()),
            child: const RtvOrdersTab(),
          ),

          // Warehouse Orders
          BlocProvider(
            create: (context) =>
                getIt<WarehouseOrderBloc>()
                  ..add(const FetchWarehouseOrderEvent(page: "1")),
            child: const WarehouseOrderScreen(),
          ),
          // Stale Orders
          BlocProvider(
            create: (context) =>
                getIt<StaleOrderBloc>()
                  ..add(const StaleOrderLoadRequested()),
            child: const StaleOrdersTab(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
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
        style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      backgroundColor: theme.primaryColor,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Create New Order',
          onPressed: () {
            context.router.push(const CreateOrderRoute());
          },
        ),

        BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              tooltip: 'Search Orders',
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: OrderSearchDelegate(
                    searchOrdersUseCase: getIt<SearchOrdersUseCase>(),
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
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
          Tab(text: 'Stale'),
        ],
      ),
    );
  }
}
