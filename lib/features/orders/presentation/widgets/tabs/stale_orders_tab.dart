import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/stale_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';

class StaleOrdersTab extends BaseOrderTabView {
  const StaleOrdersTab({super.key});

  @override
  State<StaleOrdersTab> createState() => _StaleOrdersTabState();
}

class _StaleOrdersTabState extends BaseOrderTabViewState<StaleOrdersTab> {
  @override
  void onLoadMore() {
    context.read<StaleOrderBloc>().add(const StaleOrderLoadMoreRequested());
  }

  @override
  Future<void> onRefresh() async {
    context.read<StaleOrderBloc>().add(const StaleOrderRefreshRequested());
  }



  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      const StaleOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
