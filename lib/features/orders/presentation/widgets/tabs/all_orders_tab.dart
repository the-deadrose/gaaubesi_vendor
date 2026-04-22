import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_filter_bottom_sheet.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/orders_filter_bus.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/all_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';

class AllOrdersTab extends BaseOrderTabView {
  const AllOrdersTab({super.key});

  @override
  State<AllOrdersTab> createState() => _AllOrdersTabState();
}

class _AllOrdersTabState extends BaseOrderTabViewState<AllOrdersTab> {
  static const int _tabIndex = 0;
  OrdersFilterBus? _registeredBus;

  @override
  void onLoadMore() {
    context.read<OrderBloc>().add(const OrderLoadMoreRequested());
  }

  @override
  Future<void> onRefresh() async {
    context.read<OrderBloc>().add(const OrderRefreshRequested());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bus = OrdersFilterScope.of(context);
    if (bus != _registeredBus) {
      _registeredBus?.unregister(_tabIndex, _openFilter);
      bus?.register(_tabIndex, _openFilter);
      _registeredBus = bus;
    }
  }

  @override
  void dispose() {
    _registeredBus?.unregister(_tabIndex, _openFilter);
    super.dispose();
  }

  OrderFilterConfig _configFromState() {
    final state = context.read<OrderBloc>().state;
    if (state is OrderLoaded) {
      return OrderFilterConfig(
        sourceBranch: state.sourceBranch,
        destinationBranch: state.destinationBranch,
        startDate: state.startDate,
        endDate: state.endDate,
        status: state.currentStatus,
        receiverSearch: state.search,
      );
    }
    if (state is OrderLoadingMore) {
      return OrderFilterConfig(
        sourceBranch: state.sourceBranch,
        destinationBranch: state.destinationBranch,
        startDate: state.startDate,
        endDate: state.endDate,
        status: state.currentStatus,
        receiverSearch: state.search,
      );
    }
    return const OrderFilterConfig();
  }

  Future<void> _openFilter() async {
    final result = await OrderFilterBottomSheet.show(
      context: context,
      initialConfig: _configFromState(),
      filterType: OrderFilterType.all,
    );
    if (result != null && mounted) {
      context.read<OrderBloc>().add(
        OrderAdvancedFilterChanged(
          sourceBranch: result.sourceBranch,
          destinationBranch: result.destinationBranch,
          startDate: result.startDate,
          endDate: result.endDate,
          status: result.status,
          search: result.receiverSearch,
        ),
      );
    }
  }

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      const AllOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
