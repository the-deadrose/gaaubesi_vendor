import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/sub_branch_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/repository/contacts_repository.dart';
import 'package:injectable/injectable.dart';
@lazySingleton

class FetchSubbrachesUsecase
    implements
        UseCase<SubBranchesResponseEntity, FetchSubbrachesUsecaseParams> {
  final ContactsRepository repository;

  FetchSubbrachesUsecase({required this.repository});

  @override
  Future<Either<Failure, SubBranchesResponseEntity>> call(
    FetchSubbrachesUsecaseParams params,
  ) {
    return repository.getSubBranches(
      page: params.page,
      searchQuery: params.searchQuery,
    );
  }
}

class FetchSubbrachesUsecaseParams {
  final String page;
  final String? searchQuery;

  FetchSubbrachesUsecaseParams({required this.page, this.searchQuery});
}
