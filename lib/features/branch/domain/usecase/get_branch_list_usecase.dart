import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/repository/branch_list_repository.dart';

@lazySingleton
class GetBranchListUsecase implements UseCase<List<OrderStatusEntity>, NoParams> {
  final BranchListRepository _repository;

  GetBranchListUsecase(this._repository);

  @override
  Future<Either<Failure, List<OrderStatusEntity>>> call(NoParams params) async {
    final result = await _repository.getBranchList();
    return result;
  }
}
