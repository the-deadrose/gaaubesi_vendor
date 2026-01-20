import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/stale_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/redirected_order_list_sliver.dart';

class OrdersTabsView extends StatefulWidget {
  const OrdersTabsView({super.key});

  @override
  State<OrdersTabsView> createState() => _OrdersTabsViewState();
}

class _OrdersTabsViewState extends State<OrdersTabsView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Stale Orders'),
              Tab(text: 'Redirected Orders'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              CustomScrollView(
                slivers: [
                  const StaleOrderListSliver(),
                ],
              ),
              CustomScrollView(
                slivers: [
                  const RedirectedOrderListSliver(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
