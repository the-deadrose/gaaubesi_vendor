import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

@lazySingleton
class FetchOrderDetailUseCase extends UseCase<OrderDetailEntity, int> {
  final OrderRepository repository;

  FetchOrderDetailUseCase(this.repository);

  @override
  Future<Either<Failure, OrderDetailEntity>> call(int orderId) async {
    return await repository.fetchOrderDetail(orderId: orderId);
  }
}
