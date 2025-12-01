import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/delivered_order_entity.dart';

abstract class DeliveredOrderState extends Equatable {
  const DeliveredOrderState();

  @override
  List<Object?> get props => [];
}

class DeliveredOrderInitial extends DeliveredOrderState {
  const DeliveredOrderInitial();
}

class DeliveredOrderLoading extends DeliveredOrderState {
  const DeliveredOrderLoading();
}

class DeliveredOrderLoaded extends DeliveredOrderState {
  final List<DeliveredOrderEntity> orders;
  final int currentPage;
  final bool hasMore;
  final int totalCount;
  final int totalPages;

  const DeliveredOrderLoaded({
    required this.orders,
    required this.currentPage,
    required this.hasMore,
    required this.totalCount,
    required this.totalPages,
  });

  DeliveredOrderLoaded copyWith({
    List<DeliveredOrderEntity>? orders,
    int? currentPage,
    bool? hasMore,
    int? totalCount,
    int? totalPages,
  }) {
    return DeliveredOrderLoaded(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [orders, currentPage, hasMore, totalCount, totalPages];
}

class DeliveredOrderLoadingMore extends DeliveredOrderState {
  final List<DeliveredOrderEntity> orders;
  final int currentPage;
  final int totalCount;
  final int totalPages;

  const DeliveredOrderLoadingMore({
    required this.orders,
    required this.currentPage,
    required this.totalCount,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [orders, currentPage, totalCount, totalPages];
}

class DeliveredOrderError extends DeliveredOrderState {
  final String message;

  const DeliveredOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
