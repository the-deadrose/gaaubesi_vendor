import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_event.dart';

@RoutePage()
class RedirectedOrdersScreen extends StatefulWidget {
  const RedirectedOrdersScreen({super.key});

  @override
  State<RedirectedOrdersScreen> createState() => _RedirectedOrdersScreenState();
}

class _RedirectedOrdersScreenState extends State<RedirectedOrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<RedirectedOrderItem> _orders = [];
  int _page = 1;

  @override
  void initState() {
    super.initState();
    context.read<RedirectedOrdersBloc>().add(
      FetchRedirectedOrdersEvent(page: _page),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _page++;
      context.read<RedirectedOrdersBloc>().add(
        FetchRedirectedOrdersEvent(page: _page),
      );
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
      appBar: AppBar(title: const Text('Redirected Orders')),
      body: BlocConsumer<RedirectedOrdersBloc, RedirectOrderState>(
        listener: (context, state) {
          if (state is RedirectOrdersLoaded) {
            _orders
              ..clear()
              ..addAll(state.redirectedOrders.results);
          } else if (state is RedirectOrdersPaginated) {
            _orders.addAll(state.redirectedOrders.results);
          }
        },
        builder: (context, state) {
          if (state is RedirectOrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RedirectOrdersError) {
            return Center(child: Text(state.message));
          }

          if (state is RedirectOrdersEmpty) {
            return const Center(child: Text('No redirected orders found'));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: _orders.length + 1,
            itemBuilder: (context, index) {
              if (index == _orders.length) {
                if (state is RedirectOrdersPaginating) {
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
                    'Child Order: ${order.childOrderId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parent Order: ${order.parentOrderId}'),
                      Text('Vendor: ${order.vendorName}'),
                      Text('Status: ${order.childOrderStatus}'),
                      Text(
                        'Created: ${order.createdOn.toLocal()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
