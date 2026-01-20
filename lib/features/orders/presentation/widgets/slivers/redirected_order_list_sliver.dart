import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_order_state.dart';

class RedirectedOrderListSliver extends StatelessWidget {
  const RedirectedOrderListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RedirectedOrdersBloc, RedirectOrderState>(
      builder: (context, state) {
        if (state is RedirectOrdersLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is RedirectOrdersError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RedirectedOrdersBloc>().add(FetchRedirectedOrdersEvent(page: 1));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        List<RedirectedOrderItem> orders = [];

        if (state is RedirectOrdersLoaded) {
          orders = state.redirectedOrders.results;
        }

        if (orders.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No redirected orders found'),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < orders.length) {
                final order = orders[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Card(
                    child: ListTile(
                      title: Text(order.parentOrderId),
                      subtitle: Text('${order.childOrderId}'),
                      trailing: Text(order.childOrderStatus),
                      onTap: () {
                        context.router.push(OrderDetailRoute(orderId: order.childOrderId));
                      },
                    ),
                  ),
                );
              }
              return null;
            },
            childCount: orders.length,
          ),
        );
      },
    );
  }
}
