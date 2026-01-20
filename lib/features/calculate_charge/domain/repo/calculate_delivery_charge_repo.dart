import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/entity/calculate_deliver_charge_entity.dart';

abstract class CalculateDeliveryChargeRepo {
  Future<Either<Failure, CalculateDeliveryCharge>> calculateDeliveryCharge({
    required String sourceBranchId,
    required String destinationBranchId,
    required String weight,
  });
}
