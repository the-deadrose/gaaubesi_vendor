import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/repo/payment_request_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreatePaymentRequestUsecase
    extends UseCase<void, CreatePaymentRequestParams> {
  final PaymentRequestRepo _paymentRequestRepo;
  CreatePaymentRequestUsecase(this._paymentRequestRepo);

  @override
  Future<Either<Failure, void>> call(CreatePaymentRequestParams params) {
    return _paymentRequestRepo.createPaymentRequest(
      paymentMethod: params.paymentMethod,
      description: params.description,
      bankName: params.bankName,
      accountNumber: params.accountNumber,
      accountName: params.accountName,
      phoneNumber: params.phoneNumber,
    );
  }
}

class CreatePaymentRequestParams {
  final String paymentMethod;
  final String description;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String phoneNumber;

  CreatePaymentRequestParams({
    required this.paymentMethod,
    required this.description,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.phoneNumber,
  });
}
