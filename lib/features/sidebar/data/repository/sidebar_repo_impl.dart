import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/sidebar/data/datasource/sidebar_datasource.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/entity/sidebar_entity.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/repository/sidebar_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SidebarRepository)
class SidebarRepoImpl implements SidebarRepository {
  final SidebarDatasource _sidebarDatasource;
  SidebarRepoImpl(this._sidebarDatasource);

  @override
  Future<Either<Failure, List<SideBarEntity>>> getSidebarData() {
    try {
      final result = _sidebarDatasource.getSidebarData();
      return result;
    } catch (e) {
      return Future.value(
        Left(ServerFailure('Failed to get sidebar data: $e')),
      );
    }
  }
}
