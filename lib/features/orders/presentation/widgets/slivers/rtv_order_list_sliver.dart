import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/rtv_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/base_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/rtv_order_card.dart';

class RtvOrderListSliver extends StatelessWidget {
  const RtvOrderListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericOrderListSliver<RtvOrderBloc, RtvOrderState, RtvOrderEntity>(
      isLoading: (state) => state is RtvOrderLoading,
      isError: (state) => state is RtvOrderError,
      isLoadedOrLoadingMore: (state) =>
          state is RtvOrderLoaded || state is RtvOrderLoadingMore,
      isLoadingMore: (state) => state is RtvOrderLoadingMore,
      getErrorMessage: (state) =>
          state is RtvOrderError ? state.message : 'Unknown error',
      getOrders: (state) {
        if (state is RtvOrderLoaded) return state.orders;
        if (state is RtvOrderLoadingMore) return state.orders;
        return [];
      },
      buildCard: (order) => RtvOrderCard(
        order: order,
        onTap: () {
          final orderIdInt = int.tryParse(order.orderId);
          if (orderIdInt != null) {
            context.router.push(OrderDetailRoute(orderId: orderIdInt));
          }
        },
      ),
      onRetry: () {
        context.read<RtvOrderBloc>().add(const RtvOrderRefreshRequested());
      },
    );
  }
}
