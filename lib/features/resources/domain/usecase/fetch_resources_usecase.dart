import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/resources/domain/entity/resources_list_entity.dart';
import 'package:gaaubesi_vendor/features/resources/domain/repository/resources_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchResourcesUsecase
    implements UseCase<ResourcesListEntity, FetchResourcesParams> {
  final ResourcesRepository _repository;

  FetchResourcesUsecase(this._repository);

  @override
  Future<Either<Failure, ResourcesListEntity>> call(
    FetchResourcesParams params,
  ) {
    return _repository.fetchResourcesList(
      searchQuery: params.searchQuery,
      page: params.page,
    );
  }
}

class FetchResourcesParams {
  final String? searchQuery;
  final String page;

  FetchResourcesParams({this.searchQuery, this.page = '1'});
}
