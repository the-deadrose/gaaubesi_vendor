import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/today_redirected_order_list_sliver.dart';

class TodayRedirectOrderTab extends StatefulWidget {
  const TodayRedirectOrderTab({super.key});

  @override
  State<TodayRedirectOrderTab> createState() => _TodayRedirectOrderTabState();
} 

class _TodayRedirectOrderTabState extends State<TodayRedirectOrderTab> {
  @override
  void initState() {
    super.initState();
    context.read<RedirectedOrdersBloc>().add(FetchTodaysRedirectedOrdersEvent(page: 1));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<RedirectedOrdersBloc>().add(FetchTodaysRedirectedOrdersEvent(page: 1));
      },
      child: CustomScrollView(
        slivers: [
          const TodayRedirectedOrderListSliver(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}