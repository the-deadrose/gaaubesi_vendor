import 'package:flutter/rendering.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/analysis/data/model/branch_report_analysis_model.dart';
import 'package:gaaubesi_vendor/features/analysis/data/model/delivery_report_analysis_model.dart';
import 'package:gaaubesi_vendor/features/analysis/data/model/pickup_order_analysis_model.dart';
import 'package:gaaubesi_vendor/features/analysis/data/model/sales_report_analysis_model.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/branch_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/pickup_order_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/sales_report_analysis_entity.dart';
import 'package:injectable/injectable.dart';

abstract class AnalysisDatasource {
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

@LazySingleton(as: AnalysisDatasource)
class AnalysisDatasourceImpl implements AnalysisDatasource {
  final DioClient _dioClient;
  AnalysisDatasourceImpl(this._dioClient);
  @override
  Future<Either<Failure, DeliveryReportAnalysisEntity>>
  fetchDeliveryReportAnalysis({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final queryParameters = {'from_date': startDate, 'to_date': endDate};
      final response = await _dioClient.get(
        ApiEndpoints.deliveryReportAnalysis,
        queryParameters: queryParameters,
      );

      return right(DeliveryReportAnalysisModel.fromJson(response.data));
    } catch (e) {
      return left(
        ServerFailure('Failed to fetch delivery report analysis data.'),
      );
    }
  }

  @override
  Future<Either<Failure, SalesReportAnalysis>> fetchSalesReportAnalysis({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final queryParameters = {'from_date': startDate, 'to_date': endDate};
      final response = await _dioClient.get(
        ApiEndpoints.salesReportAnalysis,
        queryParameters: queryParameters,
      );
      return right(SalesReportAnalysisModel.fromJson(response.data).toEntity());
    } catch (e) {
      return left(ServerFailure('Failed to fetch sales report analysis data.'));
    }
  }

  @override
  Future<Either<Failure, List<BranchReportAnalysisEntity>>>
  fetchBranchReportAnalysis({
    required String startDate,
    required String endDate,
    String? branch,
  }) async {
    try {
      final queryParameters = {
        'from_date': startDate,
        'to_date': endDate,
        'branch': ?branch,
      };

      debugPrint(' Endpoint: ${ApiEndpoints.branchReportAnalysis}');
      debugPrint(' Query Parameters: $queryParameters');

      final response = await _dioClient.get(
        ApiEndpoints.branchReportAnalysis,
        queryParameters: queryParameters,
      );

      debugPrint(' Status Code: ${response.statusCode}');
      debugPrint('Response Type: ${response.data.runtimeType}');
      debugPrint('Full Response: ${response.data}');
      debugPrint(
        'Response Keys: ${response.data is Map ? response.data.keys.toList() : 'N/A (not a Map)'}',
      );

      List<BranchReportAnalysisEntity> reports = [];

      if (response.data is List) {
        debugPrint('Response is List type');
        reports = (response.data as List)
            .map((item) => BranchReportAnalysisModel.fromJson(item).toEntity())
            .toList();
      } else if (response.data is Map) {
        debugPrint('Response is Map type');
        debugPrint('  Available keys: ${(response.data as Map).keys.toList()}');

        dynamic data;

        if (response.data.containsKey('branch_analysis')) {
          debugPrint('  Found "branch_analysis" key');
          data = response.data['branch_analysis'];
          debugPrint('  branch_analysis type: ${data.runtimeType}');
          debugPrint('  branch_analysis content: $data');
        } else if (response.data.containsKey('data')) {
          debugPrint('   Found "data" key (fallback)');
          data = response.data['data'];
          debugPrint('   data type: ${data.runtimeType}');
          debugPrint('  data content: $data');
        } else {
          debugPrint('   Neither "branch_analysis" nor "data" key found!');
        }

        if (data is List) {
          debugPrint('   Data is List, converting to entities...');
          reports = data
              .map(
                (item) => BranchReportAnalysisModel.fromJson(item).toEntity(),
              )
              .toList();
          debugPrint('   Converted ${reports.length} items to entities');
        } else {
          debugPrint('   Data is not a List type: ${data.runtimeType}');
        }
      } else {
        debugPrint(
          ' Response is neither List nor Map: ${response.data.runtimeType}',
        );
      }

      debugPrint('Total reports: ${reports.length}');
      if (reports.isNotEmpty) {
        debugPrint(' First report:');
        final first = reports.first;
        debugPrint(' Name: ${first.name}');
        debugPrint(' ID: ${first.destinationBranch}');
        debugPrint(' Total: ${first.total}');
        debugPrint(' Processing: ${first.processingOrders}');
        debugPrint(' Delivered: ${first.delivered}');
        debugPrint(' Returned: ${first.returned}');
      }

      return right(reports);
    } catch (e, stackTrace) {
      debugPrint(' Error: $e');
      debugPrint(' Stack Trace: $stackTrace');

      return left(
        ServerFailure('Failed to fetch branch report analysis data: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<PickupOrderAnalysisEntity>>>
  fetchPickupOrderAnalysis({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final queryParameters = {'from_date': startDate, 'to_date': endDate};
      
      debugPrint('🔍 Pickup Analysis Request:');
      debugPrint('   Endpoint: ${ApiEndpoints.pickupOrderAnalysis}');
      debugPrint('   Query Parameters: $queryParameters');
      
      final response = await _dioClient.get(
        ApiEndpoints.pickupOrderAnalysis,
        queryParameters: queryParameters,
      );
      
      debugPrint('📦 Pickup Analysis Response:');
      debugPrint('   Status Code: ${response.statusCode}');
      debugPrint('   Response Type: ${response.data.runtimeType}');
      debugPrint('   Full Response: ${response.data}');
      
      List<PickupOrderAnalysisEntity> reports = [];
      
      if (response.data is Map) {
        debugPrint('✅ Response is Map type - converting to entity');
        final analysis = PickupOrderAnalysisModel.fromJson(
          response.data as Map<String, dynamic>,
        ).toEntity();
        reports = [analysis];
        debugPrint('   Converted to entity: ${analysis.fromDate} - ${analysis.toDate}');
      } else if (response.data is List) {
        debugPrint('✅ Response is List type - processing list items');
        reports = (response.data as List)
            .map((item) => PickupOrderAnalysisModel.fromJson(item).toEntity())
            .toList();
        debugPrint('   Processed ${reports.length} items');
      } else {
        debugPrint('❌ Response is unexpected type: ${response.data.runtimeType}');
        return left(
          ServerFailure(
            'Unexpected response type: ${response.data.runtimeType}',
          ),
        );
      }
      
      return right(reports);
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching pickup order analysis:');
      debugPrint('   Error: $e');
      debugPrint('   Stack Trace: $stackTrace');
      return left(
        ServerFailure('Failed to fetch pickup order analysis data: $e'),
      );
    }
  }
}
