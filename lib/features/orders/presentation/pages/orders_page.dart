import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/search_orders_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/all_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/delivered_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/possible_redirect_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/redirected_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/returned_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/rtv_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/stale_orders_tab.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/warehouse_order_screen.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/orders_filter_bus.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_search_delegate.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/today_redirect_order_tab.dart';

const _bgCanvas = Color(0xFFF6F7FB);
const _surface = Colors.white;
const _ink = Color(0xFF0F172A);
const _inkSoft = Color(0xFF475569);
const _inkMuted = Color(0xFF94A3B8);
const _hairline = Color(0xFFE2E8F0);

const _tabs = <String>[
  'All Orders',
  'Delivered',
  'Possible Redirect',
  'Returned',
  'RTV',
  'Warehouse',
  'Stale',
  'Redirected',
  "Today's Redirected",
];

@RoutePage()
class OrdersPage extends StatelessWidget {
  final int initialTab;

  const OrdersPage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderBloc>()..add(const OrderLoadRequested()),
      child: _OrdersView(initialTab: initialTab),
    );
  }
}

class _OrdersView extends StatefulWidget {
  final int initialTab;

  const _OrdersView({this.initialTab = 0});

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrdersFilterBus _filterBus = OrdersFilterBus();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _openSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: OrderSearchDelegate(
        searchOrdersUseCase: getIt<SearchOrdersUseCase>(),
        onSearchQueryChanged: (_) {},
        onClearRecentSearches: () {},
      ),
    );
  }

  void _openFilterForCurrentTab(BuildContext context) {
    HapticFeedback.selectionClick();
    final index = _tabController.index;
    final opened = _filterBus.openFilter(index);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            backgroundColor: _ink,
            content: Text(
              'Filters aren\'t available for ${_tabs[index]}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrdersFilterScope(
      bus: _filterBus,
      child: Scaffold(
        backgroundColor: _bgCanvas,
        appBar: _buildAppBar(context),
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
                  getIt<StaleOrderBloc>()..add(const StaleOrderLoadRequested()),
              child: const StaleOrdersTab(),
            ),
            // Redirected Orders
            BlocProvider(
              create: (context) =>
                  getIt<RedirectedOrdersBloc>()
                    ..add(FetchRedirectedOrdersEvent(page: 1)),
              child: const RedirectedOrdersTab(),
            ),

            // Today's Redirected Orders
            BlocProvider(
              create: (context) =>
                  getIt<RedirectedOrdersBloc>()
                    ..add(FetchTodaysRedirectedOrdersEvent(page: 1)),
              child: const TodayRedirectOrderTab(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
  color: Colors.white,
),
      backgroundColor: AppTheme.marianBlue,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      toolbarHeight: 56,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppTheme.marianBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      
      title: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(
          'My Orders',
          style: GoogleFonts.inter(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      actions: [
        _NewOrderAction(
          onTap: () => context.router.push(const CreateOrderRoute()),
        ),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(116),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: _surface,
            border: Border(bottom: BorderSide(color: _hairline, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: _SearchField(
                  onSearchTap: () => _openSearch(context),
                  onFilterTap: () => _openFilterForCurrentTab(context),
                ),
              ),
              SizedBox(
                height: 54,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      child: _buildTabBar(),
                    ),
                    const Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 28,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0x00FFFFFF), _surface],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => AppTheme.marianBlue.withValues(alpha: 0.06),
      ),
      splashBorderRadius: BorderRadius.circular(999),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: AppTheme.marianBlue,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      labelColor: Colors.white,
      unselectedLabelColor: _inkSoft,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.zero,
      tabs: [
        for (final label in _tabs)
          Tab(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(label),
            ),
          ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  const _SearchField({required this.onSearchTap, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _bgCanvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _hairline, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onSearchTap,
                splashColor: AppTheme.marianBlue.withValues(alpha: 0.06),
                highlightColor: AppTheme.marianBlue.withValues(alpha: 0.04),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: _inkMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search by order ID',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: _inkMuted,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.05,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(height: 22, width: 1, color: _hairline),
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onFilterTap,
              splashColor: AppTheme.marianBlue.withValues(alpha: 0.08),
              highlightColor: AppTheme.marianBlue.withValues(alpha: 0.04),
              child: SizedBox(
                width: 48,
                height: 46,
                child: Tooltip(
                  message: 'Filter orders',
                  child: Center(
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppTheme.marianBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewOrderAction extends StatelessWidget {
  final VoidCallback onTap;

  const _NewOrderAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppTheme.marianBlue.withValues(alpha: 0.12),
          highlightColor: AppTheme.marianBlue.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: AppTheme.marianBlue,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'New',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.marianBlue,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
