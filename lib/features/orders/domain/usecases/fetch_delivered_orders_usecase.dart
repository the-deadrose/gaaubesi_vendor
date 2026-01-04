import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_delivered_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

@lazySingleton
class FetchDeliveredOrdersUseCase
    extends
        UseCase<
          PaginatedDeliveredOrderResponseEntity,
          FetchDeliveredOrdersParams
        > {
  final OrderRepository repository;

  FetchDeliveredOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedDeliveredOrderResponseEntity>> call(
    FetchDeliveredOrdersParams params,
  ) async {
    return await repository.fetchDeliveredOrders(
      page: params.page,
      destination: params.destination,
      startDate: params.startDate,
      endDate: params.endDate,
      receiverSearch: params.receiverSearch,
      minCharge: params.minCharge,
      maxCharge: params.maxCharge,
    );
  }
}

class FetchDeliveredOrdersParams extends Equatable {
  final int page;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;
  final double? minCharge;
  final double? maxCharge;

  const FetchDeliveredOrdersParams({
    required this.page,
    this.destination,
    this.startDate,
    this.endDate,
    this.receiverSearch,
    this.minCharge,
    this.maxCharge,
  });

  @override
  List<Object?> get props => [
    page,
    destination,
    startDate,
    endDate,
    receiverSearch,
    minCharge,
    maxCharge,
  ];
}
