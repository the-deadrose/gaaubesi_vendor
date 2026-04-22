import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_filter_bottom_sheet.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/orders_filter_bus.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/delivered_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';

class DeliveredOrdersTab extends BaseOrderTabView {
  const DeliveredOrdersTab({super.key});

  @override
  State<DeliveredOrdersTab> createState() => _DeliveredOrdersTabState();
}

class _DeliveredOrdersTabState
    extends BaseOrderTabViewState<DeliveredOrdersTab> {
  static const int _tabIndex = 1;
  OrdersFilterBus? _registeredBus;

  @override
  void onLoadMore() {
    context.read<DeliveredOrderBloc>().add(
      const DeliveredOrderLoadMoreRequested(),
    );
  }

  @override
  Future<void> onRefresh() async {
    context.read<DeliveredOrderBloc>().add(
      const DeliveredOrderRefreshRequested(),
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
    final state = context.read<DeliveredOrderBloc>().state;
    if (state is DeliveredOrderLoaded) {
      return OrderFilterConfig(
        destination: state.destination,
        startDate: state.startDate,
        endDate: state.endDate,
        receiverSearch: state.receiverSearch,
      );
    }
    if (state is DeliveredOrderLoadingMore) {
      return OrderFilterConfig(
        destination: state.destination,
        startDate: state.startDate,
        endDate: state.endDate,
        receiverSearch: state.receiverSearch,
      );
    }
    return const OrderFilterConfig();
  }

  Future<void> _openFilter() async {
    final result = await OrderFilterBottomSheet.show(
      context: context,
      initialConfig: _configFromState(),
      filterType: OrderFilterType.delivered,
    );
    if (result != null && mounted) {
      context.read<DeliveredOrderBloc>().add(
        DeliveredOrderFilterChanged(
          destination: result.destination,
          startDate: result.startDate,
          endDate: result.endDate,
          receiverSearch: result.receiverSearch,
        ),
      );
    }
  }

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      const DeliveredOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
