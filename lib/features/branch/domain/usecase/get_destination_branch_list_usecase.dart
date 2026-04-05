import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/repository/branch_list_repository.dart';

@lazySingleton
class GetDestinationBranchListUsecase
    implements UseCase<List<BranchListEntity>, BranchParams> {
  final BranchListRepository _repository;

  GetDestinationBranchListUsecase(this._repository);

  @override
  Future<Either<Failure, List<BranchListEntity>>> call(
    BranchParams params,
  ) async {
    final result = await _repository.getDestinationBranch(params.branch);
    return result;  // Already returns a list from the repository
  }
}

class BranchParams {
  final String branch;

  BranchParams(this.branch);
}
