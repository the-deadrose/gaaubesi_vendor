import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

@lazySingleton
class FetchOrdersUseCase
    extends UseCase<PaginatedOrderResponseEntity, FetchOrdersParams> {
  final OrderRepository repository;

  FetchOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedOrderResponseEntity>> call(
    FetchOrdersParams params,
  ) async {
    return await repository.fetchOrders(
      page: params.page,
      status: params.status,
      sourceBranch: params.sourceBranch,
      destinationBranch: params.destinationBranch,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class FetchOrdersParams extends Equatable {
  final int page;
  final String? status;
  final String? sourceBranch;
  final String? destinationBranch;
  final String? startDate;
  final String? endDate;

  const FetchOrdersParams({
    required this.page,
    this.status,
    this.sourceBranch,
    this.destinationBranch,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    page,
    status,
    sourceBranch,
    destinationBranch,
    startDate,
    endDate,
  ];
}
