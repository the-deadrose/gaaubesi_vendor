import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/pickup_order_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/repository/analysis_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchPickupOrderAnalysisUsecase
    implements
        UseCase<
          List<PickupOrderAnalysisEntity>,
          FetchPickupOrderAnalysisUsecaseParams
        > {
  final AnalysisRepository _repository;
  FetchPickupOrderAnalysisUsecase(this._repository);

  @override
  Future<Either<Failure, List<PickupOrderAnalysisEntity>>> call(
    FetchPickupOrderAnalysisUsecaseParams params,
  ) {
    return _repository.fetchPickupOrderAnalysis(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class FetchPickupOrderAnalysisUsecaseParams {
  final String startDate;
  final String endDate;

  FetchPickupOrderAnalysisUsecaseParams({
    required this.startDate,
    required this.endDate,
  });
}
