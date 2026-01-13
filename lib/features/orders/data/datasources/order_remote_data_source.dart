import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_delivered_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_possible_redirect_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_returned_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_rtv_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/create_order_request_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/edit_order_request_model.dart';
import 'package:gaaubesi_vendor/features/orderdetail/data/model/order_detail_model.dart';

abstract class OrderRemoteDataSource {
  Future<PaginatedOrderResponseModel> fetchOrders({
    required int page,
    String? status,
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
  });

  Future<PaginatedDeliveredOrderResponseModel> fetchDeliveredOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  });

  Future<PaginatedPossibleRedirectOrderResponseModel>
  fetchPossibleRedirectOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  });

  Future<PaginatedReturnedOrderResponseModel> fetchReturnedOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  });

  Future<PaginatedRtvOrderResponseModel> fetchRtvOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  });

  Future<void> createOrder({required CreateOrderRequestModel request});

  Future<OrderDetailModel> fetchOrderDetail({required int orderId});

  Future<void> editOrder({
    required int orderId,
    required EditOrderRequestModel request,
  });

  Future<PaginatedOrderResponseModel> searchOrderId({String? orderId});
}

@LazySingleton(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PaginatedOrderResponseModel> fetchOrders({
    required int page,
    String? status,
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
    String? orderId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page};

      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }
      if (sourceBranch != null && sourceBranch.isNotEmpty) {
        queryParameters['source_branch'] = sourceBranch;
      }
      if (destinationBranch != null && destinationBranch.isNotEmpty) {
        queryParameters['destination_branch'] = destinationBranch;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParameters['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParameters['end_date'] = endDate;
      }
      //search = order_id

      final response = await _dioClient.get(
        ApiEndpoints.orderList,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return PaginatedOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to fetch orders');
      }
    } on DioException catch (e) {
      // Extract error message from response if available
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.isNotEmpty) {
          // Try to get the first error message from the map
          // The error format seems to be {field: [error_message]}
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            errorMessage = firstValue.first.toString();
          } else if (firstValue is String) {
            errorMessage = firstValue;
          }
        }
      }

      throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<PaginatedDeliveredOrderResponseModel> fetchDeliveredOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) async {
    // try {
    final queryParameters = <String, dynamic>{'page': page};
    if (destination != null) queryParameters['destination'] = destination;
    if (startDate != null) queryParameters['start_date'] = startDate;
    if (endDate != null) queryParameters['end_date'] = endDate;
    if (receiverSearch != null) {
      queryParameters['receiver_search'] = receiverSearch;
    }
    if (minCharge != null) queryParameters['min_charge'] = minCharge;
    if (maxCharge != null) queryParameters['max_charge'] = maxCharge;

    final response = await _dioClient.get(
      ApiEndpoints.vendorDeliveredList,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return PaginatedDeliveredOrderResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } else {
      throw ServerException('Failed to fetch delivered orders');
    }
    // } on DioException catch (e) {
    //   String errorMessage = e.message ?? 'Unknown error';
    //   if (e.response?.data != null && e.response?.data is Map) {
    //     final data = e.response?.data as Map;
    //     if (data.isNotEmpty) {
    //       final firstValue = data.values.first;
    //       if (firstValue is List && firstValue.isNotEmpty) {
    //         errorMessage = firstValue.first.toString();
    //       } else if (firstValue is String) {
    //         errorMessage = firstValue;
    //       }
    //     }
    //   }

    //   throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    // }
  }

  @override
  Future<PaginatedPossibleRedirectOrderResponseModel>
  fetchPossibleRedirectOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) async {
    // try {
    final queryParameters = <String, dynamic>{'page': page};
    if (destination != null) queryParameters['destination'] = destination;
    if (startDate != null) queryParameters['start_date'] = startDate;
    if (endDate != null) queryParameters['end_date'] = endDate;
    if (receiverSearch != null) {
      queryParameters['receiver_search'] = receiverSearch;
    }
    if (minCharge != null) queryParameters['min_charge'] = minCharge;
    if (maxCharge != null) queryParameters['max_charge'] = maxCharge;

    final response = await _dioClient.get(
      ApiEndpoints.vendorPossibleRedirect,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return PaginatedPossibleRedirectOrderResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } else {
      throw ServerException('Failed to fetch possible redirect orders');
    }
    // } on DioException catch (e) {
    //   String errorMessage = e.message ?? 'Unknown error';
    //   if (e.response?.data != null && e.response?.data is Map) {
    //     final data = e.response?.data as Map;
    //     if (data.isNotEmpty) {
    //       final firstValue = data.values.first;
    //       if (firstValue is List && firstValue.isNotEmpty) {
    //         errorMessage = firstValue.first.toString();
    //       } else if (firstValue is String) {
    //         errorMessage = firstValue;
    //       }
    //     }
    //   }

    //   throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    // }
  }

  @override
  Future<PaginatedReturnedOrderResponseModel> fetchReturnedOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page};
      if (destination != null) queryParameters['destination'] = destination;
      if (startDate != null) queryParameters['start_date'] = startDate;
      if (endDate != null) queryParameters['end_date'] = endDate;
      if (receiverSearch != null) {
        queryParameters['receiver_search'] = receiverSearch;
      }
      if (minCharge != null) queryParameters['min_charge'] = minCharge;
      if (maxCharge != null) queryParameters['max_charge'] = maxCharge;

      final response = await _dioClient.get(
        ApiEndpoints.vendorReturnedOrders,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return PaginatedReturnedOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to fetch returned orders');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            errorMessage = firstValue.first.toString();
          } else if (firstValue is String) {
            errorMessage = firstValue;
          }
        }
      }

      throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<PaginatedRtvOrderResponseModel> fetchRtvOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page};
      if (destination != null) queryParameters['destination'] = destination;
      if (startDate != null) queryParameters['start_date'] = startDate;
      if (endDate != null) queryParameters['end_date'] = endDate;
      if (receiverSearch != null) {
        queryParameters['receiver_search'] = receiverSearch;
      }
      if (minCharge != null) queryParameters['min_charge'] = minCharge;
      if (maxCharge != null) queryParameters['max_charge'] = maxCharge;

      final response = await _dioClient.get(
        ApiEndpoints.vendorRtvList,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return PaginatedRtvOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to fetch RTV orders');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            errorMessage = firstValue.first.toString();
          } else if (firstValue is String) {
            errorMessage = firstValue;
          }
        }
      }

      throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> createOrder({required CreateOrderRequestModel request}) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.vendorCreateOrder,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw ServerException('Failed to create order');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            errorMessage = firstValue.first.toString();
          } else if (firstValue is String) {
            errorMessage = firstValue;
          }
        }
      }

      throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<OrderDetailModel> fetchOrderDetail({required int orderId}) async {
    try {
      final response = await _dioClient.get(
        '${ApiEndpoints.orderDetail}/$orderId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('Raw API response: $data');

        // Check if response has a nested 'data' field
        final jsonData = data is Map<String, dynamic>
            ? (data['data'] as Map<String, dynamic>? ?? data)
            : data as Map<String, dynamic>;

        debugPrint('Processed JSON data: $jsonData');
        debugPrint('Keys in JSON: ${jsonData.keys.toList()}');

        final orderDetail = OrderDetailModel.fromJson(jsonData);
        debugPrint(
          'Messages in order detail: ${orderDetail.messages?.length ?? 0}',
        );

        return orderDetail;
      } else {
        throw ServerException('Failed to fetch order details');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            errorMessage = firstValue.first.toString();
          } else if (firstValue is String) {
            errorMessage = firstValue;
          }
        }
      }

      throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> editOrder({
    required int orderId,
    required EditOrderRequestModel request,
  }) async {
    try {
      final response = await _dioClient.put(
        '${ApiEndpoints.editOrder}$orderId/',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to edit order');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            errorMessage = firstValue.first.toString();
          } else if (firstValue is String) {
            errorMessage = firstValue;
          }
        }
      }

      throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<PaginatedOrderResponseModel> searchOrderId({String? orderId}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (orderId != null && orderId.isNotEmpty) {
        queryParameters['search'] = orderId;
      }

      final response = await _dioClient.get(
        ApiEndpoints.orderList,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return PaginatedOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to search orders by ID');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.isNotEmpty) {
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            errorMessage = firstValue.first.toString();
          } else if (firstValue is String) {
            errorMessage = firstValue;
          }
        }
      }

      throw ServerException(errorMessage, statusCode: e.response?.statusCode);
    }
  }
}
