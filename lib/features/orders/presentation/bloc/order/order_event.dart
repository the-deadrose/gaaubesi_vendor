import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/create_order_request_entity.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderLoadRequested extends OrderEvent {
  final String? status;

  const OrderLoadRequested({this.status});

  @override
  List<Object?> get props => [status];
}

class OrderRefreshRequested extends OrderEvent {
  final String? status;

  const OrderRefreshRequested({this.status});

  @override
  List<Object?> get props => [status];
}

class OrderLoadMoreRequested extends OrderEvent {
  const OrderLoadMoreRequested();
}

class OrderStatusFilterChanged extends OrderEvent {
  final String? status;

  const OrderStatusFilterChanged({this.status});

  @override
  List<Object?> get props => [status];
}

class OrderSearchQueryChanged extends OrderEvent {
  final String query;

  const OrderSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class OrderFilterChanged extends OrderEvent {
  final String filterId;

  const OrderFilterChanged(this.filterId);

  @override
  List<Object?> get props => [filterId];
}

class OrderAdvancedFilterChanged extends OrderEvent {
  final String? sourceBranch;
  final String? destinationBranch;
  final String? startDate;
  final String? endDate;
  final String? status;

  const OrderAdvancedFilterChanged({
    this.sourceBranch,
    this.destinationBranch,
    this.startDate,
    this.endDate,
    this.status,
  });

  @override
  List<Object?> get props => [
    sourceBranch,
    destinationBranch,
    startDate,
    endDate,
    status,
  ];
}

class OrderStatsRequested extends OrderEvent {
  const OrderStatsRequested();
}

class OrderCreateRequested extends OrderEvent {
  final CreateOrderRequestEntity request;

  const OrderCreateRequested({required this.request});

  @override
  List<Object?> get props => [request];
}
