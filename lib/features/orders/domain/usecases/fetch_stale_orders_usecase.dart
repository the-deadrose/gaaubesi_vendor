import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_stale_orders_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

@lazySingleton
class FetchStaleOrdersUseCase
    extends UseCase<PaginatedStaleOrdersResponseEntity, FetchStaleOrdersParams> {
  final OrderRepository repository;

  FetchStaleOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedStaleOrdersResponseEntity>> call(
    FetchStaleOrdersParams params,
  ) async {
    return await repository.fetchStaleOrders(page: params.page);
  }
}

class FetchStaleOrdersParams extends Equatable {
  final int page;

  const FetchStaleOrdersParams({required this.page});

  @override
  List<Object?> get props => [page];
}
