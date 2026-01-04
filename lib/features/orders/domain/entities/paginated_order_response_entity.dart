import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';

class PaginatedOrderResponseEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<OrderEntity> results;

  const PaginatedOrderResponseEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasMore => next != null;

  @override
  List<Object?> get props => [count, next, previous, results];
}
