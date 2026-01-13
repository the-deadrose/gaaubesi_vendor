import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

@lazySingleton
class SearchOrdersUseCase
    extends UseCase<List<OrderEntity>, SearchOrdersParams> {
  final OrderRepository repository;

  SearchOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
    SearchOrdersParams params,
  ) async {
    return await repository.searchOrders(
      query: params.query,
      limit: params.limit,
    );
  }
}

class SearchOrdersParams extends Equatable {
  final String query;
  final int? limit;

  const SearchOrdersParams({required this.query, this.limit});

  @override
  List<Object?> get props => [query, limit];
}
