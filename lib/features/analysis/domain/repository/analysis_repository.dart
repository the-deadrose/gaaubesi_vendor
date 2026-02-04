import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/branch_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/pickup_order_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/sales_report_analysis_entity.dart';

abstract class AnalysisRepository {
  Future<Either<Failure, DeliveryReportAnalysisEntity>>
  fetchDeliveryReportAnalysis({
    required String startDate,
    required String endDate,
  });

  Future<Either<Failure, SalesReportAnalysis>> fetchSalesReportAnalysis({
    required String startDate,
    required String endDate,
  });

  Future<Either<Failure, List<BranchReportAnalysisEntity>>>
  fetchBranchReportAnalysis({
    required String startDate,
    required String endDate,
    String? branch,
  });

  Future<Either<Failure, List<PickupOrderAnalysisEntity>>>
  fetchPickupOrderAnalysis({
    required String startDate,
    required String endDate,
  });
}
