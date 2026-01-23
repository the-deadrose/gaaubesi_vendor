import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/repo/extra_mileage_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ExtraMileageUsecase
    extends UseCase<ExtraMileageResponseListEntity, ExtraMileageParams> {
  final ExtraMileageRepo extraMileageRepo;
  ExtraMileageUsecase(this.extraMileageRepo);
  @override
  Future<Either<Failure, ExtraMileageResponseListEntity>> call(
    ExtraMileageParams params,
  ) {
    return extraMileageRepo.fetchExtraMileageList(
      params.page,
      params.status,
      params.startDate,
      params.endDate,
    );
  }
}

class ExtraMileageParams {
  final String page;
  final String status;
  final String startDate;
  final String endDate;

  ExtraMileageParams({
    required this.page,
    required this.status,
    required this.startDate,
    required this.endDate,
  });
}
