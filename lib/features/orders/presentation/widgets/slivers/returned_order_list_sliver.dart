import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/base_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/returned_order_card.dart';

class ReturnedOrderListSliver extends StatelessWidget {
  const ReturnedOrderListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericOrderListSliver<
      ReturnedOrderBloc,
      ReturnedOrderState,
      ReturnedOrderEntity
    >(
      isLoading: (state) => state is ReturnedOrderLoading,
      isError: (state) => state is ReturnedOrderError,
      isLoadedOrLoadingMore: (state) =>
          state is ReturnedOrderLoaded || state is ReturnedOrderLoadingMore,
      isLoadingMore: (state) => state is ReturnedOrderLoadingMore,
      getErrorMessage: (state) =>
          state is ReturnedOrderError ? state.message : 'Unknown error',
      getOrders: (state) {
        if (state is ReturnedOrderLoaded) return state.orders;
        if (state is ReturnedOrderLoadingMore) return state.orders;
        return [];
      },
      buildCard: (order) => ReturnedOrderCard(
        order: order,
        onTap: () {
          context.router.push(OrderDetailRoute(orderId: order.orderId));
        },
      ),
      onRetry: () {
        context.read<ReturnedOrderBloc>().add(
          const ReturnedOrderRefreshRequested(),
        );
      },
    );
  }
}
