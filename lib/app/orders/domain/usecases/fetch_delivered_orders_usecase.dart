import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/paginated_delivered_order_response_entity.dart';
import 'package:gaaubesi_vendor/app/orders/domain/repositories/order_repository.dart';

@lazySingleton
class FetchDeliveredOrdersUseCase extends UseCase<
    PaginatedDeliveredOrderResponseEntity, FetchDeliveredOrdersParams> {
  final OrderRepository repository;

  FetchDeliveredOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedDeliveredOrderResponseEntity>> call(
    FetchDeliveredOrdersParams params,
  ) async {
    return await repository.fetchDeliveredOrders(page: params.page);
  }
}

class FetchDeliveredOrdersParams extends Equatable {
  final int page;

  const FetchDeliveredOrdersParams({required this.page});

  @override
  List<Object?> get props => [page];
}
