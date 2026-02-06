import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/repo/extra_mileage_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApproveExtraMileageUsecase
    implements UseCase<void, ApproveExtraMileageUsecaseParams> {
  final ExtraMileageRepo _extraMileageRepo;

  ApproveExtraMileageUsecase(this._extraMileageRepo);

  @override
  Future<Either<Failure, void>> call(ApproveExtraMileageUsecaseParams params) {
    return _extraMileageRepo.approveExtraMileage(params.mileageId);
  }
}

class ApproveExtraMileageUsecaseParams {
  final String mileageId;

  ApproveExtraMileageUsecaseParams({required this.mileageId});
}
