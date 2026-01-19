import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/stale_orders_entity.dart';

class PaginatedStaleOrdersResponseEntity extends Equatable {
  final List<StaleOrdersEntity> results;
  final int count;
  final bool hasMore;

  const PaginatedStaleOrdersResponseEntity({
    required this.results,
    required this.count,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [results, count, hasMore];
}
