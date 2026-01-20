import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/entity/calculate_deliver_charge_entity.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/repo/calculate_delivery_charge_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton

 class CalculateDeliveryChargeUsecase
    extends
        UseCase<CalculateDeliveryCharge, CalculateDeliveryChargeUsecaseParams> {
  final CalculateDeliveryChargeRepo _repository;

  CalculateDeliveryChargeUsecase(this._repository);

  @override
  Future<Either<Failure, CalculateDeliveryCharge>> call(
    CalculateDeliveryChargeUsecaseParams params,
  ) async {
    final result = await _repository.calculateDeliveryCharge(
      sourceBranchId: params.sourceBranchId,
      destinationBranchId: params.destinationBranchId,
      weight: params.weight,
    );
    return result;
  }
}

class CalculateDeliveryChargeUsecaseParams {
  final String sourceBranchId;
  final String destinationBranchId;
  final String weight;

  CalculateDeliveryChargeUsecaseParams({
    required this.sourceBranchId,
    required this.destinationBranchId,
    required this.weight,
  });
}
