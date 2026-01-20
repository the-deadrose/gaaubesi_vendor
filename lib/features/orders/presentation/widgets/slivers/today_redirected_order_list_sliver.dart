import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/today_redirect_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_order_state.dart';

class TodayRedirectedOrderListSliver extends StatelessWidget {
  const TodayRedirectedOrderListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RedirectedOrdersBloc, RedirectOrderState>(
      builder: (context, state) {
        if (state is TodaysRedirectedOrderLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TodaysRedirectedOrderError) {
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
                      context.read<RedirectedOrdersBloc>().add(
                        FetchTodaysRedirectedOrdersEvent(page: 1),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        List<TodayRedirectOrder> orders = [];

        if (state is TodaysRedirectedOrderLoaded) {
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
                  const Text('No redirected orders for today'),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
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
                      context.router.push(
                        OrderDetailRoute(orderId: order.childOrderId),
                      );
                    },
                  ),
                ),
              );
            }
            return null;
          }, childCount: orders.length),
        );
      },
    );
  }
}
