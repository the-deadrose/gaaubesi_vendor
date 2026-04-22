import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_filter_bottom_sheet.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/orders_filter_bus.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/rtv_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';

class RtvOrdersTab extends BaseOrderTabView {
  const RtvOrdersTab({super.key});

  @override
  State<RtvOrdersTab> createState() => _RtvOrdersTabState();
}

class _RtvOrdersTabState extends BaseOrderTabViewState<RtvOrdersTab> {
  static const int _tabIndex = 4;
  OrdersFilterBus? _registeredBus;

  @override
  void onLoadMore() {
    context.read<RtvOrderBloc>().add(const RtvOrderLoadMoreRequested());
  }

  @override
  Future<void> onRefresh() async {
    context.read<RtvOrderBloc>().add(const RtvOrderRefreshRequested());
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
    final state = context.read<RtvOrderBloc>().state;
    if (state is RtvOrderLoaded) {
      return OrderFilterConfig(
        destination: state.destination,
        startDate: state.startDate,
        endDate: state.endDate,
        receiverSearch: state.receiverSearch,
     
      );
    }
    if (state is RtvOrderLoadingMore) {
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
      filterType: OrderFilterType.rtv,
    );
    if (result != null && mounted) {
      context.read<RtvOrderBloc>().add(
        RtvOrderFilterChanged(
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
      const RtvOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
