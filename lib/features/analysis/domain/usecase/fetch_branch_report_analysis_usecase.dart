import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/branch_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/repository/analysis_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchBranchReportAnalysisUsecase
    implements
        UseCase<
          List<BranchReportAnalysisEntity>,
          FetchBranchReportAnalysisUsecaseParams
        > {
  final AnalysisRepository _repository;

  FetchBranchReportAnalysisUsecase(this._repository);

  @override
  Future<Either<Failure, List<BranchReportAnalysisEntity>>> call(
    FetchBranchReportAnalysisUsecaseParams params,
  ) {
    return _repository.fetchBranchReportAnalysis(
      startDate: params.startDate,
      endDate: params.endDate,
      branch: params.branch,
    );
  }
}

class FetchBranchReportAnalysisUsecaseParams {
  final String startDate;
  final String endDate;
  final String? branch;

  FetchBranchReportAnalysisUsecaseParams({
    required this.startDate,
    required this.endDate,
    this.branch,
  });
}
