import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_possible_redirect_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

@lazySingleton
class FetchPossibleRedirectOrdersUseCase
    extends
        UseCase<
          PaginatedPossibleRedirectOrderResponseEntity,
          FetchPossibleRedirectOrdersParams
        > {
  final OrderRepository repository;

  FetchPossibleRedirectOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedPossibleRedirectOrderResponseEntity>> call(
    FetchPossibleRedirectOrdersParams params,
  ) async {
    return await repository.fetchPossibleRedirectOrders(
      page: params.page,
      destination: params.destination,
      startDate: params.startDate,
      endDate: params.endDate,
      receiverSearch: params.receiverSearch,
    );
  }
}

class FetchPossibleRedirectOrdersParams extends Equatable {
  final int page;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;

  const FetchPossibleRedirectOrdersParams({
    required this.page,
    this.destination,
    this.startDate,
    this.endDate,
    this.receiverSearch,
  });

  @override
  List<Object?> get props => [
    page,
    destination,
    startDate,
    endDate,
    receiverSearch,
  ];
}
