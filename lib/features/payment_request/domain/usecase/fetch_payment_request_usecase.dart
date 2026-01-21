import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/repo/payment_request_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchPaymentRequestUsecase
    extends
        UseCase<PaymentRequestListEntity, FetchPaymentRequestUsecaseParams> {
  final PaymentRequestRepo _paymentRequestRepo;
  FetchPaymentRequestUsecase(this._paymentRequestRepo);

  @override
  Future<Either<Failure, PaymentRequestListEntity>> call(
    FetchPaymentRequestUsecaseParams params,
  ) {
    return _paymentRequestRepo.getPaymentRequests(
      page: params.page,
      status: params.status,
      paymentMethod: params.paymentMethod,
      bankName: params.bankName,
    );
  }
}

class FetchPaymentRequestUsecaseParams {
  final String page;
  final String status;
  final String paymentMethod;
  final String bankName;

  FetchPaymentRequestUsecaseParams({
    required this.page,
    required this.status,
    required this.paymentMethod,
    required this.bankName,
  });
}
