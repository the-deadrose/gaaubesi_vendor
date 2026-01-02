import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/possible_redirect_order_entity.dart';

class PaginatedPossibleRedirectOrderResponseEntity extends Equatable {
  final int totalPages;
  final String? next;
  final String? previous;
  final List<PossibleRedirectOrderEntity> results;

  const PaginatedPossibleRedirectOrderResponseEntity({
    required this.totalPages,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasMore => next != null;

  @override
  List<Object?> get props => [totalPages, next, previous, results];
}
