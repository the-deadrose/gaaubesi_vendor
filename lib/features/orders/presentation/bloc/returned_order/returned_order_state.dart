import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_order_entity.dart';

abstract class ReturnedOrderState extends Equatable {
  const ReturnedOrderState();

  @override
  List<Object?> get props => [];
}

class ReturnedOrderInitial extends ReturnedOrderState {
  const ReturnedOrderInitial();
}

class ReturnedOrderLoading extends ReturnedOrderState {
  const ReturnedOrderLoading();
}

class ReturnedOrderLoaded extends ReturnedOrderState {
  final List<ReturnedOrderEntity> orders;
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

  const ReturnedOrderLoaded({
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

  ReturnedOrderLoaded copyWith({
    List<ReturnedOrderEntity>? orders,
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
    return ReturnedOrderLoaded(
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

class ReturnedOrderLoadingMore extends ReturnedOrderState {
  final List<ReturnedOrderEntity> orders;
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

  const ReturnedOrderLoadingMore({
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

class ReturnedOrderError extends ReturnedOrderState {
  final String message;

  const ReturnedOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
