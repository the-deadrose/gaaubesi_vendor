import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/sales_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/repository/analysis_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchSalesReportAnalysisUsecase
    implements
        UseCase<SalesReportAnalysis, FetchSalesReportAnalysisUsecaseParams> {
  final AnalysisRepository _repository;
  FetchSalesReportAnalysisUsecase(this._repository);

  @override
  Future<Either<Failure, SalesReportAnalysis>> call(
    FetchSalesReportAnalysisUsecaseParams params,
  ) {
    return _repository.fetchSalesReportAnalysis(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class FetchSalesReportAnalysisUsecaseParams {
  final String startDate;
  final String endDate;

  FetchSalesReportAnalysisUsecaseParams({
    required this.startDate,
    required this.endDate,
  });
}
