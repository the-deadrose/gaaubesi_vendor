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
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;
  final double? minCharge;
  final double? maxCharge;

  const DeliveredOrderLoaded({
    required this.orders,
    required this.currentPage,
    required this.hasMore,
    required this.totalCount,
    required this.totalPages,
    this.destination,
    this.startDate,
    this.endDate,
    this.receiverSearch,
    this.minCharge,
    this.maxCharge,
  });

  DeliveredOrderLoaded copyWith({
    List<DeliveredOrderEntity>? orders,
    int? currentPage,
    bool? hasMore,
    int? totalCount,
    int? totalPages,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) {
    return DeliveredOrderLoaded(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      receiverSearch: receiverSearch ?? this.receiverSearch,
      minCharge: minCharge ?? this.minCharge,
      maxCharge: maxCharge ?? this.maxCharge,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    currentPage,
    hasMore,
    totalCount,
    totalPages,
    destination,
    startDate,
    endDate,
    receiverSearch,
    minCharge,
    maxCharge,
  ];
}

class DeliveredOrderLoadingMore extends DeliveredOrderState {
  final List<DeliveredOrderEntity> orders;
  final int currentPage;
  final int totalCount;
  final int totalPages;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;
  final double? minCharge;
  final double? maxCharge;

  const DeliveredOrderLoadingMore({
    required this.orders,
    required this.currentPage,
    required this.totalCount,
    required this.totalPages,
    this.destination,
    this.startDate,
    this.endDate,
    this.receiverSearch,
    this.minCharge,
    this.maxCharge,
  });

  @override
  List<Object?> get props => [
    orders,
    currentPage,
    totalCount,
    totalPages,
    destination,
    startDate,
    endDate,
    receiverSearch,
    minCharge,
    maxCharge,
  ];
}

class DeliveredOrderError extends DeliveredOrderState {
  final String message;

  const DeliveredOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
