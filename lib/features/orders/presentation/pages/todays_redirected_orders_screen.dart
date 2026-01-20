import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/today_redirect_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_order_state.dart';

@RoutePage()
class TodaysRedirectedOrdersScreen extends StatefulWidget {
  const TodaysRedirectedOrdersScreen({super.key});

  @override
  State<TodaysRedirectedOrdersScreen> createState() =>
      _TodaysRedirectedOrdersScreenState();
}

class _TodaysRedirectedOrdersScreenState
    extends State<TodaysRedirectedOrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<TodayRedirectOrder> _orders = [];

  int _page = 1;

  @override
  void initState() {
    super.initState();

    _fetchOrders();

    _scrollController.addListener(_onScroll);
  }

  void _fetchOrders() {
    context.read<RedirectedOrdersBloc>().add(
          FetchTodaysRedirectedOrdersEvent(page: _page),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _page++;
      _fetchOrders();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Redirected Orders")),
      body: BlocConsumer<RedirectedOrdersBloc, RedirectOrderState>(
        listener: (context, state) {
          if (state is TodaysRedirectedOrderLoaded) {
            _orders
              ..clear()
              ..addAll(state.redirectedOrders.results);
          } else if (state is TodaysRedirectedOrderPaginated) {
            _orders.addAll(state.redirectedOrders.results);
          }
        },
        builder: (context, state) {
          if (state is TodaysRedirectedOrderLoading && _orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TodaysRedirectedOrderError) {
            return Center(child: Text(state.message));
          }

          if (_orders.isEmpty) {
            return const Center(child: Text('No redirected orders for today'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _page = 1;
              _fetchOrders();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _orders.length + 1,
              itemBuilder: (context, index) {
                if (index == _orders.length) {
                  if (state is TodaysRedirectedOrderPaginating) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final order = _orders[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      'Child Order #${order.childOrderId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Parent Order: ${order.parentOrderId}'),
                        Text('Status: ${order.childOrderStatus}',
                            style: const TextStyle(color: Colors.blueGrey)),
                        const SizedBox(height: 4),
                        Text(
                          'COD: ₹${order.childCodCharge.toStringAsFixed(2)}',
                        ),
                        Text(
                          'Parent Delivery Charge: ${order.parentDeliveryCharge}',
                        ),
                        Text(
                          'Child Delivery Charge: ₹${order.childDeliveryCharge.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${order.createdOn.toLocal()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
