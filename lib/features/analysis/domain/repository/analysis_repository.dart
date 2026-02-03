import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';

abstract class AnalysisRepository  {
  Future<Either<Failure, DeliveryReportAnalysisEntity>>
  fetchDeliveryReportAnalysis({
    required String startDate,
    required String endDate,
  });
}
