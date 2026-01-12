import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/edit_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

class EditOrderParams {
  final int orderId;
  final OrderEditEntity request;

  EditOrderParams({
    required this.orderId,
    required this.request,
  });
}

@lazySingleton
class EditOrderUseCase extends UseCase<void, EditOrderParams> {
  final OrderRepository repository;

  EditOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(EditOrderParams params) async {
    return await repository.editOrder(
      orderId: params.orderId,
      request: params.request,
    );
  }
}
