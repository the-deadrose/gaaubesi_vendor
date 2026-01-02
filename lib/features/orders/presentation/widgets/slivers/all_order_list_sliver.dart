import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/base_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_card.dart';

class AllOrderListSliver extends StatelessWidget {
  const AllOrderListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericOrderListSliver<OrderBloc, OrderState, OrderEntity>(
      isLoading: (state) => state is OrderLoading,
      isError: (state) => state is OrderError,
      isLoadedOrLoadingMore: (state) =>
          state is OrderLoaded || state is OrderLoadingMore,
      isLoadingMore: (state) => state is OrderLoadingMore,
      getErrorMessage: (state) =>
          state is OrderError ? state.message : 'Unknown error',
      getOrders: (state) {
        if (state is OrderLoaded) return state.orders;
        if (state is OrderLoadingMore) return state.orders;
        return [];
      },
      buildCard: (order) => OrderCard(
        order: order,
        onTap: () {
          // TODO: Navigate to order details
        },
      ),
      onRetry: () {
        context.read<OrderBloc>().add(const OrderRefreshRequested());
      },
    );
  }
}
