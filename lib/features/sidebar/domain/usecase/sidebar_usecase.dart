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
