import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/delivered_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/base_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/delivered_order_card.dart';

class DeliveredOrderListSliver extends StatelessWidget {
  const DeliveredOrderListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericOrderListSliver<
      DeliveredOrderBloc,
      DeliveredOrderState,
      DeliveredOrderEntity
    >(
      isLoading: (state) => state is DeliveredOrderLoading,
      isError: (state) => state is DeliveredOrderError,
      isLoadedOrLoadingMore: (state) =>
          state is DeliveredOrderLoaded || state is DeliveredOrderLoadingMore,
      isLoadingMore: (state) => state is DeliveredOrderLoadingMore,
      getErrorMessage: (state) =>
          state is DeliveredOrderError ? state.message : 'Unknown error',
      getOrders: (state) {
        if (state is DeliveredOrderLoaded) return state.orders;
        if (state is DeliveredOrderLoadingMore) return state.orders;
        return [];
      },
      buildCard: (deliveredOrder) {
        return DeliveredOrderCard(
          order: deliveredOrder,
          onTap: () {
            context.router.push(OrderDetailRoute(orderId: deliveredOrder.orderId));
          },
        );
      },
      onRetry: () {
        context.read<DeliveredOrderBloc>().add(
          const DeliveredOrderRefreshRequested(),
        );
      },
    );
  }
}
