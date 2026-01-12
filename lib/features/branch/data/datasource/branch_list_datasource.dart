import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/branch/data/model/branch_list_model.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';

abstract class BranchListRemoteDatasource {
  Future<List<OrderStatusEntity>> fetchBranchList();
}

@LazySingleton(as: BranchListRemoteDatasource)
class BranchListDatasourceImpl implements BranchListRemoteDatasource {
  BranchListDatasourceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<List<OrderStatusEntity>> fetchBranchList() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.branchList,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final branchList = data
            .map((json) => OrderStatusModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
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
}
