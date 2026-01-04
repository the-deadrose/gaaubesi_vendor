import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/order_entity.dart';

class OrderStats extends Equatable {
  final int total;
  final int inTransit;
  final int delivered;

  const OrderStats({this.total = 0, this.inTransit = 0, this.delivered = 0});

  @override
  List<Object?> get props => [total, inTransit, delivered];
}

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final List<OrderEntity> orders;
  final int currentPage;
  final bool hasMore;
  final String? currentStatus;
  final String searchQuery;
  final Set<String> activeFilters;
  final OrderStats stats;
  final String? sourceBranch;
  final String? destinationBranch;
  final String? startDate;
  final String? endDate;

  const OrderLoaded({
    required this.orders,
    required this.currentPage,
    required this.hasMore,
    this.currentStatus,
    this.searchQuery = '',
    this.activeFilters = const {},
    this.stats = const OrderStats(),
    this.sourceBranch,
    this.destinationBranch,
    this.startDate,
    this.endDate,
  });

  OrderLoaded copyWith({
    List<OrderEntity>? orders,
    int? currentPage,
    bool? hasMore,
    String? currentStatus,
    String? searchQuery,
    Set<String>? activeFilters,
    OrderStats? stats,
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
  }) {
    return OrderLoaded(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      currentStatus: currentStatus ?? this.currentStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      stats: stats ?? this.stats,
      sourceBranch: sourceBranch ?? this.sourceBranch,
      destinationBranch: destinationBranch ?? this.destinationBranch,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    currentPage,
    hasMore,
    currentStatus,
    searchQuery,
    activeFilters,
    stats,
    sourceBranch,
    destinationBranch,
    startDate,
    endDate,
  ];
}

class OrderLoadingMore extends OrderState {
  final List<OrderEntity> orders;
  final int currentPage;
  final String? currentStatus;
  final String searchQuery;
  final Set<String> activeFilters;
  final OrderStats stats;
  final String? sourceBranch;
  final String? destinationBranch;
  final String? startDate;
  final String? endDate;

  const OrderLoadingMore({
    required this.orders,
    required this.currentPage,
    this.currentStatus,
    this.searchQuery = '',
    this.activeFilters = const {},
    this.stats = const OrderStats(),
    this.sourceBranch,
    this.destinationBranch,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    orders,
    currentPage,
    currentStatus,
    searchQuery,
    activeFilters,
    stats,
    sourceBranch,
    destinationBranch,
    startDate,
    endDate,
  ];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
