import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/rtv_order_entity.dart';

abstract class RtvOrderState extends Equatable {
  const RtvOrderState();

  @override
  List<Object?> get props => [];
}

class RtvOrderInitial extends RtvOrderState {
  const RtvOrderInitial();
}

class RtvOrderLoading extends RtvOrderState {
  const RtvOrderLoading();
}

class RtvOrderLoaded extends RtvOrderState {
  final List<RtvOrderEntity> orders;
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

  const RtvOrderLoaded({
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

  RtvOrderLoaded copyWith({
    List<RtvOrderEntity>? orders,
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
    return RtvOrderLoaded(
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

class RtvOrderLoadingMore extends RtvOrderState {
  final List<RtvOrderEntity> orders;
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

  const RtvOrderLoadingMore({
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

class RtvOrderError extends RtvOrderState {
  final String message;

  const RtvOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
