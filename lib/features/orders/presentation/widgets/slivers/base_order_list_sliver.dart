import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_empty_view.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_error_view.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_loading_indicator.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_card_shimmer.dart';

/// Generic sliver widget for displaying order lists with common loading/error/empty states.
///
/// Type parameters:
/// - [B] - The Bloc type
/// - [S] - The State type
/// - [T] - The order entity type
class GenericOrderListSliver<B extends StateStreamable<S>, S, T>
    extends StatelessWidget {
  /// Check if current state is loading
  final bool Function(S state) isLoading;

  /// Check if current state is error
  final bool Function(S state) isError;

  /// Check if current state is loaded or loading more
  final bool Function(S state) isLoadedOrLoadingMore;

  /// Check if current state is loading more (for pagination indicator)
  final bool Function(S state) isLoadingMore;

  /// Get error message from error state
  final String Function(S state) getErrorMessage;

  /// Get orders list from loaded state
  final List<T> Function(S state) getOrders;

  /// Build the card widget for an order
  final Widget Function(T order) buildCard;

  /// Called when retry button is pressed
  final VoidCallback onRetry;

  const GenericOrderListSliver({
    super.key,
    required this.isLoading,
    required this.isError,
    required this.isLoadedOrLoadingMore,
    required this.isLoadingMore,
    required this.getErrorMessage,
    required this.getOrders,
    required this.buildCard,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      builder: (context, state) {
        if (isLoading(state)) {
          return _buildLoadingSliver();
        }

        if (isError(state)) {
          return SliverToBoxAdapter(
            child: OrderErrorView(
              message: getErrorMessage(state),
              onRetry: onRetry,
            ),
          );
        }

        if (isLoadedOrLoadingMore(state)) {
          final orders = getOrders(state);

          if (orders.isEmpty) {
            return const SliverToBoxAdapter(child: OrderEmptyView());
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= orders.length) {
                return const OrderLoadingIndicator();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: buildCard(orders[index]),
              );
            }, childCount: orders.length + (isLoadingMore(state) ? 1 : 0)),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildLoadingSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OrderCardShimmer(),
        ),
        childCount: 5,
      ),
    );
  }
}
