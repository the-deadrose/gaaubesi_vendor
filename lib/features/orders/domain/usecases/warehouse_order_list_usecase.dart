import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/ware_house_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WarehouseOrderListUsecase
    extends UseCase<WarehouseOrdersListEntity, WarehouseParams> {
  final OrderRepository repository;

  WarehouseOrderListUsecase(this.repository);

  @override
  Future<Either<Failure, WarehouseOrdersListEntity>> call(
    WarehouseParams params,
  ) async {
    return await repository.wareHouseList(page: params.page);
  }
}

class WarehouseParams extends Equatable {
  final String page;

  const WarehouseParams({required this.page});

  @override
  List<Object?> get props => [page];
}
