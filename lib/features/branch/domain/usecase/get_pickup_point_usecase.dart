import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/pickup_point_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/repository/branch_list_repository.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/base_usecase.dart';

@lazySingleton
class GetPickupPointUsecase
    implements UseCase<List<PickupPointEntity>, NoParams> {
  final BranchListRepository _repository;

  GetPickupPointUsecase(this._repository);

  @override
  Future<Either<Failure, List<PickupPointEntity>>> call(NoParams params) async {
    final result = await _repository.getPickupPoints();
    return result;
  }
}
