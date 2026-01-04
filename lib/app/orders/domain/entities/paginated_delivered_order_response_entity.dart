import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/delivered_order_entity.dart';

class PaginatedDeliveredOrderResponseEntity extends Equatable {
  final int count;
  final int totalPages;
  final String? next;
  final String? previous;
  final List<DeliveredOrderEntity> results;

  const PaginatedDeliveredOrderResponseEntity({
    required this.count,
    required this.totalPages,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasMore => next != null;

  @override
  List<Object?> get props => [count, totalPages, next, previous, results];
}
