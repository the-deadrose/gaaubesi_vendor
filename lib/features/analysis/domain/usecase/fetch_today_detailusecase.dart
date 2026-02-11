import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/today_detail_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/repository/analysis_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchTodayDetailusecase
    extends UseCase<TodayDetailEntity, FetchTodayDetailusecaseParams> {
  final AnalysisRepository _repository;

  FetchTodayDetailusecase(this._repository);

  @override
  Future<Either<Failure, TodayDetailEntity>> call(
    FetchTodayDetailusecaseParams params,
  ) {
    return _repository.fetchTodayDetails(status: params.status);
  }
}

class FetchTodayDetailusecaseParams {
  final String status;

  FetchTodayDetailusecaseParams({required this.status});
}
