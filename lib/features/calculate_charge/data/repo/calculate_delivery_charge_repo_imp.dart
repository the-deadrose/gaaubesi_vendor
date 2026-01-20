import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/data/datasource/calculate_delivery_charge_datasource.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/entity/calculate_deliver_charge_entity.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/repo/calculate_delivery_charge_repo.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: CalculateDeliveryChargeRepo)

class CalculateDeliveryChargeRepoImp implements CalculateDeliveryChargeRepo {
  final CalculateDeliveryChargeRemoteDatasource remoteDatasource;
  CalculateDeliveryChargeRepoImp({required this.remoteDatasource});

  @override
  Future<Either<Failure, CalculateDeliveryCharge>> calculateDeliveryCharge({
    required String sourceBranchId,
    required String destinationBranchId,
    required String weight,
  }) async {
    try {
      final deliveryCharge = await remoteDatasource.calculateDeliveryCharge(
        sourceBranchId: sourceBranchId,
        destinationBranchId: destinationBranchId,
        weight: weight,
      );
      return right(deliveryCharge);
    } catch (e) {
      rethrow;
    }
  }
}
