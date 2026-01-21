import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/frequently_used_and_payment_method_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/repo/payment_request_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchFrequentlyUsedPaymentUsecase
    extends UseCase<FrequentlyUsedAndPaymentMethodList, NoParams> {
  final PaymentRequestRepo _paymentRequestRepo;
  FetchFrequentlyUsedPaymentUsecase(this._paymentRequestRepo);

  @override
  Future<Either<Failure, FrequentlyUsedAndPaymentMethodList>> call(
    NoParams params,
  ) {
    return _paymentRequestRepo.getFrequentlyUsedMethodDetails();
  }
}
