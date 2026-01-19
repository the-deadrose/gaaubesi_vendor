import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/stale_orders_entity.dart';

abstract class StaleOrderState extends Equatable {
  const StaleOrderState();

  @override
  List<Object?> get props => [];
}

class StaleOrderInitial extends StaleOrderState {
  const StaleOrderInitial();
}

class StaleOrderLoading extends StaleOrderState {
  const StaleOrderLoading();
}

class StaleOrderLoaded extends StaleOrderState {
  final List<StaleOrdersEntity> orders;
  final int currentPage;
  final bool hasMore;

  const StaleOrderLoaded({
    required this.orders,
    required this.currentPage,
    required this.hasMore,
  });

  StaleOrderLoaded copyWith({
    List<StaleOrdersEntity>? orders,
    int? currentPage,
    bool? hasMore,
  }) {
    return StaleOrderLoaded(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [orders, currentPage, hasMore];
}

class StaleOrderLoadingMore extends StaleOrderState {
  final List<StaleOrdersEntity> orders;
  final int currentPage;

  const StaleOrderLoadingMore({
    required this.orders,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [orders, currentPage];
}

class StaleOrderError extends StaleOrderState {
  final String message;

  const StaleOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
