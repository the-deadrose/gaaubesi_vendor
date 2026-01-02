import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/possible_redirect_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/base_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/possible_redirect_order_card.dart';

class PossibleRedirectOrderListSliver extends StatelessWidget {
  const PossibleRedirectOrderListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericOrderListSliver<
      PossibleRedirectOrderBloc,
      PossibleRedirectOrderState,
      PossibleRedirectOrderEntity
    >(
      isLoading: (state) => state is PossibleRedirectOrderLoading,
      isError: (state) => state is PossibleRedirectOrderError,
      isLoadedOrLoadingMore: (state) =>
          state is PossibleRedirectOrderLoaded ||
          state is PossibleRedirectOrderLoadingMore,
      isLoadingMore: (state) => state is PossibleRedirectOrderLoadingMore,
      getErrorMessage: (state) =>
          state is PossibleRedirectOrderError ? state.message : 'Unknown error',
      getOrders: (state) {
        if (state is PossibleRedirectOrderLoaded) return state.orders;
        if (state is PossibleRedirectOrderLoadingMore) return state.orders;
        return [];
      },
      buildCard: (order) => PossibleRedirectOrderCard(order: order),
      onRetry: () {
        context.read<PossibleRedirectOrderBloc>().add(
          const PossibleRedirectOrderRefreshRequested(),
        );
      },
    );
  }
}
