import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/payments/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payments/domain/repo/payment_request_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PayementRequestListUsecase extends UseCase<PaymentRequestList, NoParams> {
  final PaymentRequestRepo _repository;

  PayementRequestListUsecase(this._repository);

  @override
  Future<Either<Failure, PaymentRequestList>> call(params) async {
    return await _repository.getPaymentRequestList();
  }
}
