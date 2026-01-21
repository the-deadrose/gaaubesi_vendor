import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/frequently_used_and_payment_method_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/payment_request_list_entity.dart';

abstract class PaymentRequestRepo {
  Future<Either<Failure, FrequentlyUsedAndPaymentMethodList>>
  getFrequentlyUsedMethodDetails();

  Future<Either<Failure, void>> createPaymentRequest({
    required String paymentMethod,
    required String description,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String phoneNumber,
  });

  Future<Either<Failure, PaymentRequestListEntity>> getPaymentRequests({
    required String page,
    required String status,
    required String paymentMethod,
    required String bankName,
  });
}
