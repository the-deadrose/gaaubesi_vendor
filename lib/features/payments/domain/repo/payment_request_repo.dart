import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';

import 'package:gaaubesi_vendor/features/payments/domain/entity/payment_request_list_entity.dart';

abstract class PaymentRequestRepo {
  Future<Either<Failure, PaymentRequestList>> getPaymentRequestList();
}
