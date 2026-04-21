import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaaubesi_vendor/features/branch/data/model/pickup_point_model.dart';
import 'package:gaaubesi_vendor/features/branch/data/model/redirect_station_list_model.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/pickup_point_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/redirect_station_list_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/configure/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/core/network/dio_exception_mapper.dart';
import 'package:gaaubesi_vendor/features/branch/data/model/branch_list_model.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';

abstract class BranchListRemoteDatasource {
  Future<List<BranchListEntity>> fetchBranchList(String branch);
  Future<List<PickupPointEntity>> fetchPickupPoints();
  Future<RedirectStationListEntity> fetchRedirectStations({
    required String page,
    String? searchQuery,
  });

  Future<List<BranchListEntity>> fetchdestinationBranch(String branch);
}

@LazySingleton(as: BranchListRemoteDatasource)
class BranchListDatasourceImpl implements BranchListRemoteDatasource {
  BranchListDatasourceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<List<BranchListEntity>> fetchBranchList(String branch) async {
    debugPrint('[BRANCH_LIST_DATASOURCE] FETCHING BRANCH LIST');

    try {
      final response = await _dioClient.get(
        ApiEndpoints.branchList,
        queryParameters: {'search': branch},
      );

      debugPrint(
        '[BRANCH_LIST_DATASOURCE]  Response received, status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        debugPrint(
          '[BRANCH_LIST_DATASOURCE]  Response data type: ${responseData.runtimeType}',
        );
        debugPrint('[BRANCH_LIST_DATASOURCE]  Response data: $responseData');

        final List<dynamic> data;

        if (responseData is Map<String, dynamic>) {
          debugPrint('[BRANCH_LIST_DATASOURCE]   Extracting from Map');
          debugPrint(
            '[BRANCH_LIST_DATASOURCE]  Keys available: ${responseData.keys.toList()}',
          );

          final rawData =
              responseData['data'] ??
              responseData['results'] ??
              responseData['branches'];

          debugPrint(
            '[BRANCH_LIST_DATASOURCE]  Raw data found: ${rawData != null}',
          );
          debugPrint(
            '[BRANCH_LIST_DATASOURCE]  Raw data type: ${rawData?.runtimeType}',
          );

          data = (rawData ?? []) as List<dynamic>;
          debugPrint(
            '[BRANCH_LIST_DATASOURCE] Extracted list length: ${data.length}',
          );

          if (data.isNotEmpty) {
            debugPrint('[BRANCH_LIST_DATASOURCE]  First item: ${data.first}');
          }
        } else if (responseData is List) {
          debugPrint('[BRANCH_LIST_DATASOURCE]  Response is already a List');
          data = responseData;
        } else {
          throw ServerException('Unexpected response format');
        }

        debugPrint('[BRANCH_LIST_DATASOURCE]  Processing ${data.length} items');
        final branchList = <BranchListEntity>[];

        for (var i = 0; i < data.length; i++) {
          try {
            debugPrint('[BRANCH_LIST_DATASOURCE]  Item $i: ${data[i]}');
            final model = BranchListModel.fromJson(
              data[i] as Map<String, dynamic>,
            );
            debugPrint(
              '[BRANCH_LIST_DATASOURCE]  Model $i: id=${model.id}, code="${model.code}", name="${model.name}"',
            );
            final entity = model.toEntity();
            debugPrint(
              '[BRANCH_LIST_DATASOURCE] Entity $i: value="${entity.value}", label="${entity.label}", code="${entity.code}"',
            );
            branchList.add(entity);
          } catch (e) {
            debugPrint(
              '[BRANCH_LIST_DATASOURCE]  Error processing item $i: $e',
            );
          }
        }

        debugPrint(
          '[BRANCH_LIST_DATASOURCE]  Successfully converted ${branchList.length} entities',
        );
        return branchList;
      } else {
        throw ServerException('Failed to fetch branch list');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      throw mapDioException(e);
    }
  }

  @override
  Future<List<PickupPointEntity>> fetchPickupPoints() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.pickupPoints);
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        final List<dynamic> data;

        if (responseData is Map<String, dynamic>) {
          data =
              (responseData['data'] ??
                      responseData['results'] ??
                      responseData['pickup_points'] ??
                      [])
                  as List<dynamic>;
        } else if (responseData is List) {
          data = responseData;
        } else {
          throw ServerException('Unexpected response format');
        }

        final pickupPoints = data
            .map(
              (json) => PickupPointModel.fromJson(json as Map<String, dynamic>),
            )
            .map((model) => model.toEntity())
            .toList();
        return pickupPoints;
      } else {
        throw ServerException('Failed to fetch pickup points');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      throw mapDioException(e);
    }
  }

  @override
  Future<RedirectStationListEntity> fetchRedirectStations({
    required String page,
    String? searchQuery,
  }) async {
    try {
      final queryParams = {
        'page': page,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      };
      final response = await _dioClient.get(
        ApiEndpoints.redirectStations,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        if (responseData is! Map<String, dynamic>) {
          throw ServerException('Unexpected response format');
        }
        final model = RedirectStationListModel.fromJson(responseData);
        return model.toEntity();
      } else {
        throw ServerException('Failed to fetch redirect stations');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      throw mapDioException(e);
    }
  }

  @override
  Future<List<BranchListEntity>> fetchdestinationBranch(String branch) async {
    try {
      final response = await _dioClient.get(
        "${ApiEndpoints.orderCreateDestinationBranchList}destination/",
        queryParameters: {'search': branch },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        if (responseData is! Map<String, dynamic>) {
          throw ServerException('Unexpected response format');
        }
        
        // Extract results array from paginated response
        final resultsList = responseData['results'] as List?;
        if (resultsList == null || resultsList.isEmpty) {
          debugPrint('[BRANCH_LIST_DATASOURCE] No results found in destination branch response');
          return [];
        }
        
        // Parse each branch from results array
        final branches = resultsList
            .map((item) => BranchListModel.fromJson(item as Map<String, dynamic>).toEntity())
            .toList();
        
        debugPrint('[BRANCH_LIST_DATASOURCE] Parsed ${branches.length} destination branches');
        return branches;
      } else {
        throw ServerException('Failed to fetch destination branch');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      throw mapDioException(e);
    }
  }
}
