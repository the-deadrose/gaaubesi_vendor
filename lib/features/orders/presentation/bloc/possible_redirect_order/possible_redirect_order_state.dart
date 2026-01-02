import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/possible_redirect_order_entity.dart';

abstract class PossibleRedirectOrderState extends Equatable {
  const PossibleRedirectOrderState();

  @override
  List<Object?> get props => [];
}

class PossibleRedirectOrderInitial extends PossibleRedirectOrderState {
  const PossibleRedirectOrderInitial();
}

class PossibleRedirectOrderLoading extends PossibleRedirectOrderState {
  const PossibleRedirectOrderLoading();
}

class PossibleRedirectOrderLoaded extends PossibleRedirectOrderState {
  final List<PossibleRedirectOrderEntity> orders;
  final int currentPage;
  final bool hasMore;
  final int totalPages;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;
  final double? minCharge;
  final double? maxCharge;

  const PossibleRedirectOrderLoaded({
    required this.orders,
    required this.currentPage,
    required this.hasMore,
    required this.totalPages,
    this.destination,
    this.startDate,
    this.endDate,
    this.receiverSearch,
    this.minCharge,
    this.maxCharge,
  });

  PossibleRedirectOrderLoaded copyWith({
    List<PossibleRedirectOrderEntity>? orders,
    int? currentPage,
    bool? hasMore,
    int? totalPages,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) {
    return PossibleRedirectOrderLoaded(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
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
    totalPages,
    destination,
    startDate,
    endDate,
    receiverSearch,
    minCharge,
    maxCharge,
  ];
}

class PossibleRedirectOrderLoadingMore extends PossibleRedirectOrderState {
  final List<PossibleRedirectOrderEntity> orders;
  final int currentPage;
  final bool hasMore;
  final int totalPages;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;
  final double? minCharge;
  final double? maxCharge;

  const PossibleRedirectOrderLoadingMore({
    required this.orders,
    required this.currentPage,
    required this.hasMore,
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
    totalPages,
    destination,
    startDate,
    endDate,
    receiverSearch,
    minCharge,
    maxCharge,
  ];
}

class PossibleRedirectOrderError extends PossibleRedirectOrderState {
  final String message;

  const PossibleRedirectOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
