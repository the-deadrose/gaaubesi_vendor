import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_filter_bottom_sheet.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/orders_filter_bus.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/returned_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';

class ReturnedOrdersTab extends BaseOrderTabView {
  const ReturnedOrdersTab({super.key});

  @override
  State<ReturnedOrdersTab> createState() => _ReturnedOrdersTabState();
}

class _ReturnedOrdersTabState extends BaseOrderTabViewState<ReturnedOrdersTab> {
  static const int _tabIndex = 3;
  OrdersFilterBus? _registeredBus;

  @override
  void onLoadMore() {
    context.read<ReturnedOrderBloc>().add(
      const ReturnedOrderLoadMoreRequested(),
    );
  }

  @override
  Future<void> onRefresh() async {
    context.read<ReturnedOrderBloc>().add(
      const ReturnedOrderRefreshRequested(),
    );
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
    final state = context.read<ReturnedOrderBloc>().state;
    if (state is ReturnedOrderLoaded) {
      return OrderFilterConfig(
        destination: state.destination,
        startDate: state.startDate,
        endDate: state.endDate,
        receiverSearch: state.receiverSearch,
        minCharge: state.minCharge,
        maxCharge: state.maxCharge,
      );
    }
    if (state is ReturnedOrderLoadingMore) {
      return OrderFilterConfig(
        destination: state.destination,
        startDate: state.startDate,
        endDate: state.endDate,
        receiverSearch: state.receiverSearch,
        minCharge: state.minCharge,
        maxCharge: state.maxCharge,
      );
    }
    return const OrderFilterConfig();
  }

  Future<void> _openFilter() async {
    final result = await OrderFilterBottomSheet.show(
      context: context,
      initialConfig: _configFromState(),
      filterType: OrderFilterType.returned,
    );
    if (result != null && mounted) {
      context.read<ReturnedOrderBloc>().add(
        ReturnedOrderFilterChanged(
          destination: result.destination,
          startDate: result.startDate,
          endDate: result.endDate,
          receiverSearch: result.receiverSearch,
          minCharge: result.minCharge,
          maxCharge: result.maxCharge,
        ),
      );
    }
  }

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      const ReturnedOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
