import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/entity/sidebar_entity.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/repository/sidebar_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:injectable/injectable.dart';


@lazySingleton
class SidebarUsecase extends UseCase<List<SideBarEntity>, NoParams> {
  final SidebarRepository _sidebarRepository;

  SidebarUsecase(this._sidebarRepository);

  @override
  Future<Either<Failure, List<SideBarEntity>>> call(NoParams params) {
    return _sidebarRepository.getSidebarData();
  }
}

@lazySingleton
class GetCachedSidebarUsecase extends UseCase<List<SideBarEntity>, NoParams> {
  final SidebarRepository _sidebarRepository;

  GetCachedSidebarUsecase(this._sidebarRepository);

  @override
  Future<Either<Failure, List<SideBarEntity>>> call(NoParams params) {
    return _sidebarRepository.getCachedSidebarData();
  }
}

@lazySingleton
class ClearSidebarCacheUsecase extends UseCase<void, NoParams> {
  final SidebarRepository _sidebarRepository;

  ClearSidebarCacheUsecase(this._sidebarRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await _sidebarRepository.clearSidebarCache();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
