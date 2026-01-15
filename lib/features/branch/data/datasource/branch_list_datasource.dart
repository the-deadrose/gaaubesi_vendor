import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaaubesi_vendor/features/branch/data/model/pickup_point_model.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/pickup_point_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/branch/data/model/branch_list_model.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';

abstract class BranchListRemoteDatasource {
  Future<List<OrderStatusEntity>> fetchBranchList(String branch);
  Future<List<PickupPointEntity>> fetchPickupPoints();
}

@LazySingleton(as: BranchListRemoteDatasource)
class BranchListDatasourceImpl implements BranchListRemoteDatasource {
  BranchListDatasourceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<List<OrderStatusEntity>> fetchBranchList(String branch) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('[BRANCH_LIST_DATASOURCE] 🚀 FETCHING BRANCH LIST');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      final response = await _dioClient.get(
        ApiEndpoints.branchList,
        queryParameters: {'search': branch},
      );

      debugPrint('[BRANCH_LIST_DATASOURCE] ✅ Response received, status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        debugPrint('[BRANCH_LIST_DATASOURCE] 📦 Response data type: ${responseData.runtimeType}');
        debugPrint('[BRANCH_LIST_DATASOURCE] 📦 Response data: $responseData');
        
        final List<dynamic> data;
        
        if (responseData is Map<String, dynamic>) {
          debugPrint('[BRANCH_LIST_DATASOURCE] 🗺️  Extracting from Map');
          debugPrint('[BRANCH_LIST_DATASOURCE] 🔑 Keys available: ${responseData.keys.toList()}');
          
          final rawData = responseData['data'] ?? 
                  responseData['results'] ?? 
                  responseData['branches'];
          
          debugPrint('[BRANCH_LIST_DATASOURCE] 📋 Raw data found: ${rawData != null}');
          debugPrint('[BRANCH_LIST_DATASOURCE] 📋 Raw data type: ${rawData?.runtimeType}');
          
          data = (rawData ?? []) as List<dynamic>;
          debugPrint('[BRANCH_LIST_DATASOURCE] ✅ Extracted list length: ${data.length}');
          
          if (data.isNotEmpty) {
            debugPrint('[BRANCH_LIST_DATASOURCE] 📄 First item: ${data.first}');
          }
        } else if (responseData is List) {
          debugPrint('[BRANCH_LIST_DATASOURCE] 📋 Response is already a List');
          data = responseData;
        } else {
          throw ServerException('Unexpected response format');
        }
        
        debugPrint('[BRANCH_LIST_DATASOURCE] 🔄 Processing ${data.length} items');
        final branchList = <OrderStatusEntity>[];
        
        for (var i = 0; i < data.length; i++) {
          try {
            debugPrint('[BRANCH_LIST_DATASOURCE] 🏗️  Item $i: ${data[i]}');
            final model = OrderStatusModel.fromJson(data[i] as Map<String, dynamic>);
            debugPrint('[BRANCH_LIST_DATASOURCE] ✅ Model $i: id=${model.id}, code="${model.code}", name="${model.name}"');
            final entity = model.toEntity();
            debugPrint('[BRANCH_LIST_DATASOURCE] ✅ Entity $i: value="${entity.value}", label="${entity.label}", code="${entity.code}"');
            branchList.add(entity);
          } catch (e) {
            debugPrint('[BRANCH_LIST_DATASOURCE] ❌ Error processing item $i: $e');
          }
        }
        
        debugPrint('[BRANCH_LIST_DATASOURCE] 🎉 Successfully converted ${branchList.length} entities');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return branchList;
      } else {
        throw ServerException('Failed to fetch branch list');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('[BRANCH_LIST_DATASOURCE] Session expired, user will be redirected to login');
        rethrow;
      }
      debugPrint(
        '[BRANCH_LIST_DATASOURCE] DioException: ${e.message}, StatusCode: ${e.response?.statusCode}',
      );
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('[BRANCH_LIST_DATASOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<List<PickupPointEntity>> fetchPickupPoints() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.pickupPoints,
      );
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        final List<dynamic> data;
        
        if (responseData is Map<String, dynamic>) {
          data = (responseData['data'] ?? 
                  responseData['results'] ?? 
                  responseData['pickup_points'] ?? 
                  []) as List<dynamic>;
        } else if (responseData is List) {
          data = responseData;
        } else {
          throw ServerException('Unexpected response format');
        }
        
        final pickupPoints = data
            .map((json) => PickupPointModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
        return pickupPoints;
      } else {
        throw ServerException('Failed to fetch pickup points');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('[BRANCH_LIST_DATASOURCE] Session expired, user will be redirected to login');
        rethrow;
      }
      debugPrint(
        '[BRANCH_LIST_DATASOURCE] DioException: ${e.message}, StatusCode: ${e.response?.statusCode}',
      );
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('[BRANCH_LIST_DATASOURCE] Unexpected error: $e');
      rethrow;
    }
  }
}
