import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/stale_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_state.dart';

class StaleOrderListSliver extends StatelessWidget {
  const StaleOrderListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaleOrderBloc, StaleOrderState>(
      builder: (context, state) {
        if (state is StaleOrderLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is StaleOrderError) {
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
                      context.read<StaleOrderBloc>().add(const StaleOrderRefreshRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        List<StaleOrdersEntity> orders = [];
        bool isLoadingMore = false;

        if (state is StaleOrderLoaded) {
          orders = state.orders;
        } else if (state is StaleOrderLoadingMore) {
          orders = state.orders;
          isLoadingMore = true;
        }

        if (orders.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No stale orders found'),
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
                      title: Text(order.orderIdWithStatus),
                      subtitle: Text(order.receiverName),
                      trailing: Text(order.lastDeliveryStatus),
                      onTap: () {
                        context.router.push(OrderDetailRoute(orderId: order.orderId));
                      },
                    ),
                  ),
                );
              } else if (isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }
              return null;
            },
            childCount: isLoadingMore ? orders.length + 1 : orders.length,
          ),
        );
      },
    );
  }
}
