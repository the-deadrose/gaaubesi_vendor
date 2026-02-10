import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/sidebar/data/datasource/sidebar_datasource.dart';
import 'package:gaaubesi_vendor/features/sidebar/data/datasource/sidebar_local_datasource.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/entity/sidebar_entity.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/repository/sidebar_repository.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: SidebarRepository)
class SidebarRepoImpl implements SidebarRepository {
  final SidebarDatasource _sidebarDatasource;
  final SidebarLocalDatasource _localDatasource;
  
  SidebarRepoImpl(this._sidebarDatasource, this._localDatasource);

  @override
  Future<Either<Failure, List<SideBarEntity>>> getSidebarData() async {
    try {
      // Try to get from remote first
      final result = await _sidebarDatasource.getSidebarData();
      
      return result;
    } catch (e) {
      // If remote fails, try to get from cache
      final cachedData = await _localDatasource.getCachedSidebarData();
      if (cachedData != null && cachedData.isNotEmpty) {
        return Right(cachedData);
      }
      return Left(ServerFailure('Failed to get sidebar data: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SideBarEntity>>> getCachedSidebarData() async {
    try {
      final cachedData = await _localDatasource.getCachedSidebarData();
      if (cachedData != null && cachedData.isNotEmpty) {
        return Right(cachedData);
      }
      return Left(ServerFailure('No cached sidebar data available'));
    } catch (e) {
      return Left(ServerFailure('Failed to get cached sidebar data: $e'));
    }
  }

  @override
  Future<void> clearSidebarCache() async {
    await _localDatasource.clearSidebarCache();
  }
}
