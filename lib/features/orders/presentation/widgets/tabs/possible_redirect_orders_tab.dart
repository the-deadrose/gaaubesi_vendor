import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_filter_bottom_sheet.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/orders_filter_bus.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/possible_redirect_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';

class PossibleRedirectOrdersTab extends BaseOrderTabView {
  const PossibleRedirectOrdersTab({super.key});

  @override
  State<PossibleRedirectOrdersTab> createState() =>
      _PossibleRedirectOrdersTabState();
}

class _PossibleRedirectOrdersTabState
    extends BaseOrderTabViewState<PossibleRedirectOrdersTab> {
  static const int _tabIndex = 2;
  OrdersFilterBus? _registeredBus;

  @override
  void onLoadMore() {
    context.read<PossibleRedirectOrderBloc>().add(
      const PossibleRedirectOrderLoadMoreRequested(),
    );
  }

  @override
  Future<void> onRefresh() async {
    context.read<PossibleRedirectOrderBloc>().add(
      const PossibleRedirectOrderRefreshRequested(),
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
    final state = context.read<PossibleRedirectOrderBloc>().state;
    if (state is PossibleRedirectOrderLoaded) {
      return OrderFilterConfig(
        destination: state.destination,
        startDate: state.startDate,
        endDate: state.endDate,
        receiverSearch: state.receiverSearch,
      
      );
    }
    if (state is PossibleRedirectOrderLoadingMore) {
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
      filterType: OrderFilterType.possibleRedirect,
    );
    if (result != null && mounted) {
      context.read<PossibleRedirectOrderBloc>().add(
        PossibleRedirectOrderFilterChanged(
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
      const PossibleRedirectOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
