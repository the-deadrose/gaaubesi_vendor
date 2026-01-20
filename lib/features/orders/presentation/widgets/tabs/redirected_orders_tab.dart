import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/redirected_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';

class RedirectedOrdersTab extends BaseOrderTabView {
  const RedirectedOrdersTab({super.key});

  @override
  State<RedirectedOrdersTab> createState() => _RedirectedOrdersTabState();
}

class _RedirectedOrdersTabState extends State<RedirectedOrdersTab> {
  @override
  void initState() {
    super.initState();
    context.read<RedirectedOrdersBloc>().add(FetchRedirectedOrdersEvent(page: 1));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<RedirectedOrdersBloc>().add(FetchRedirectedOrdersEvent(page: 1));
      },
      child: CustomScrollView(
        slivers: [
          const RedirectedOrderListSliver(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}