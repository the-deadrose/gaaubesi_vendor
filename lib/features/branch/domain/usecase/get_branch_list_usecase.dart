import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/repository/branch_list_repository.dart';

@lazySingleton
class GetBranchListUsecase
    implements UseCase<List<OrderStatusEntity>, BranchParams> {
  final BranchListRepository _repository;

  GetBranchListUsecase(this._repository);

  @override
  Future<Either<Failure, List<OrderStatusEntity>>> call(
    BranchParams params,
  ) async {
    final result = await _repository.getBranchList(params.branch);
    return result;
  }
}

class BranchParams {
  final String branch;

  BranchParams(this.branch);
}
