import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/analysis/data/datasource/analysis_datasource.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/repository/analysis_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AnalysisRepository)
class AnalysisDatasourceImpl implements AnalysisRepository {
  final AnalysisDatasource _datasource;
  AnalysisDatasourceImpl(this._datasource);
  @override
  Future<Either<Failure, DeliveryReportAnalysisEntity>>
  fetchDeliveryReportAnalysis({
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _datasource.fetchDeliveryReportAnalysis(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return left(
        ServerFailure('Failed to fetch delivery report analysis data.'),
      );
    }
  }
}
