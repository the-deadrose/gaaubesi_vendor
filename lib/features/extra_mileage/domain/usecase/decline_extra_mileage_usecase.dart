import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/repo/extra_mileage_repo.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class DeclineExtraMileageUsecase implements UseCase<void, DeclineExtraMileageUsecaseParams>{
  final ExtraMileageRepo _extraMileageRepo;

  DeclineExtraMileageUsecase(this._extraMileageRepo);

  @override
  Future<Either<Failure, void>> call(DeclineExtraMileageUsecaseParams params) {
    return _extraMileageRepo.rejectExtraMileage(params.mileageId);
  }
}

class DeclineExtraMileageUsecaseParams {
  final String mileageId;

  DeclineExtraMileageUsecaseParams({required this.mileageId});
}