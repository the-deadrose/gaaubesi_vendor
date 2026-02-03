import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/repository/analysis_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchDeliveryReportUsecase
    implements
        UseCase<
          DeliveryReportAnalysisEntity,
          FetchDeliveryReportUsecaseParams
        > {
  final AnalysisRepository _repository;
  FetchDeliveryReportUsecase(this._repository);

  @override
  Future<Either<Failure, DeliveryReportAnalysisEntity>> call(
    FetchDeliveryReportUsecaseParams params,
  ) {
    return _repository.fetchDeliveryReportAnalysis(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class FetchDeliveryReportUsecaseParams {
  final String startDate;
  final String endDate;

  FetchDeliveryReportUsecaseParams({
    required this.startDate,
    required this.endDate,
  });
}
