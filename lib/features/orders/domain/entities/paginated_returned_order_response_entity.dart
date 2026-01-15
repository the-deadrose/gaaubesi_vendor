import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_delivery_entity.dart';

class PaginatedReturnedOrderResponseEntity extends Equatable {
  final int count;
  final int totalPages;
  final String? next;
  final String? previous;
  final List<ReturnedDeliveryEntity> results;

  const PaginatedReturnedOrderResponseEntity({
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
