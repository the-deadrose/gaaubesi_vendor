import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/redirect_station_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/repository/branch_list_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetRedirectStationUsecase
    implements UseCase<RedirectStationListEntity, GetRedirectstationParams> {
  final BranchListRepository _repository;

  GetRedirectStationUsecase(this._repository);

  @override
  Future<Either<Failure, RedirectStationListEntity>> call(
    GetRedirectstationParams params,
  ) async {
    final result = await _repository.getRedirectStations(
      page: params.page,
      searchQuery: params.searchQuery,
    );
    return result;
  }
}

class GetRedirectstationParams {
  final String page;
  final String? searchQuery;

  GetRedirectstationParams({required this.page, this.searchQuery});
}
