import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/analysis/data/model/delivery_report_analysis_model.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';
import 'package:injectable/injectable.dart';

abstract class AnalysisDatasource {
  Future<Either<Failure, DeliveryReportAnalysisEntity>> fetchDeliveryReportAnalysis({
    required String startDate,
    required String endDate,
  });
}

@LazySingleton(as: AnalysisDatasource)
class AnalysisDatasourceImpl implements AnalysisDatasource {
  final DioClient _dioClient;
  AnalysisDatasourceImpl(this._dioClient);
  @override
  Future<Either<Failure, DeliveryReportAnalysisEntity>> fetchDeliveryReportAnalysis({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final queryParameters = {'start_date': startDate, 'end_date': endDate};
      final response = await _dioClient.get(
        ApiEndpoints.deliveryReportAnalysis,
        queryParameters: queryParameters,
      );

      return right(DeliveryReportAnalysisModel.fromJson(response.data));
    } catch (e) {
      return left(ServerFailure(
        'Failed to fetch delivery report analysis data.',
      ));
    }
  }
}
