import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/rtv_order_entity.dart';

class PaginatedRtvOrderResponseEntity extends Equatable {
  final int count;
  final int totalPages;
  final String? next;
  final String? previous;
  final List<RtvOrderEntity> results;

  const PaginatedRtvOrderResponseEntity({
    required this.count,
    required this.totalPages,
    this.next,
    this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [count, totalPages, next, previous, results];
}
