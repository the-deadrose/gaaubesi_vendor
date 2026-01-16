import 'package:flutter/widgets.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/customer/data/model/customer_list_model.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_list_entity.dart';
import 'package:injectable/injectable.dart';



abstract class CustomerRemoteDatasource {
  Future<CustomerListResponse> getCustomerList(String page, String? searchQuery);
}

@LazySingleton(as: CustomerRemoteDatasource)
class CustomerRemoteDatasourceImpl implements CustomerRemoteDatasource {
  final DioClient _dioClient;
  CustomerRemoteDatasourceImpl(this._dioClient);
  @override
  Future<CustomerListResponse> getCustomerList(String page, String? searchQuery) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.customerList,
        queryParameters: {'page': page, 'search': searchQuery},
      );

      debugPrint('🔵 API Response: ${response.data}');
      debugPrint('🔵 Response Type: ${response.data.runtimeType}');
      
      final dynamic responseData = response.data;
      final Map<String, dynamic> jsonData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          debugPrint('🔵 Extracting from "data" field');
          jsonData = responseData['data'] as Map<String, dynamic>;
        } else {
          jsonData = responseData;
        }
      } else {
        throw Exception('Unexpected response format: ${responseData.runtimeType}');
      }
      
      debugPrint('🔵 JSON Data to parse: $jsonData');
      final model = CustomerListResponseModel.fromJson(jsonData);
      debugPrint('🔵 Parsed customers count: ${model.customers.length}');
      
      final pageNumber = int.tryParse(page) ?? 1;
      return model.toEntity(pageNumber);
    } catch (e) {
      debugPrint('🔴 Error fetching customer list: $e');
      
      if (e.toString().contains('404') || e.toString().contains('Invalid page')) {
        debugPrint('🔴 Invalid page detected, returning empty list');
        final pageNumber = int.tryParse(page) ?? 1;
        return CustomerListResponse(
          customers: [],
          currentPage: pageNumber,
          totalPages: pageNumber - 1, 
          totalCount: 0,
        );
      }
      
      rethrow;
    }
  }
}
