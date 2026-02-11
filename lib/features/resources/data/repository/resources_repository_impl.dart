import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/resources/data/datasource/resources_datasource.dart';
import 'package:gaaubesi_vendor/features/resources/domain/entity/resources_list_entity.dart';
import 'package:gaaubesi_vendor/features/resources/domain/repository/resources_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ResourcesRepository)
class ResourcesRepositoryImpl implements ResourcesRepository {
  final ResourcesDatasource _datasource;

  ResourcesRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, ResourcesListEntity>> fetchResourcesList({
    String? searchQuery,
    String page = '1',
  }) async {
    try {
      final result = await _datasource.fetchResourcesList(
        searchQuery: searchQuery,
        page: page,
      );
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
