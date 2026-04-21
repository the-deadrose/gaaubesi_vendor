import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:gaaubesi_vendor/configure/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/data/remote_call.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/orderdetail/data/model/order_detail_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/create_order_request_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/edit_order_request_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_delivered_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_possible_redirect_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_returned_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_rtv_order_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/paginated_stale_orders_response_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/redirected_orders_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/today_redirect_order_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/ware_house_orders_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/today_redirect_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/ware_house_orders_entity.dart';

abstract class OrderRemoteDataSource {
  Future<PaginatedOrderResponseModel> fetchOrders({
    required int page,
    String? status,
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
  });
  Future<PaginatedStaleOrdersResponseModel> fetchStaleOrders({
    required int page,
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
  Future<WarehouseOrdersListEntity> fetchWareHouseList(String page);
  Future<RedirectedOrders> fetchRedirectedOrders({required int page});
  Future<TodayRedirectOrderList> fetchRedirectedOrdersToday({
    required int page,
  });
}

@LazySingleton(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  void _logQueryParams(String endpoint, Map<String, dynamic> queryParams) {
    debugPrint(
      '[OrderRemoteDataSource] GET $endpoint | queryParams: $queryParams',
    );
  }

  Map<String, dynamic> _pageFilters(
    int page, {
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) {
    final q = <String, dynamic>{'page': page};
    if (destination != null) q['destination'] = destination;
    if (startDate != null) q['start_date'] = startDate;
    if (endDate != null) q['end_date'] = endDate;
    if (receiverSearch != null) q['receiver_search'] = receiverSearch;
    if (minCharge != null) q['min_charge'] = minCharge;
    if (maxCharge != null) q['max_charge'] = maxCharge;
    return q;
  }

  @override
  Future<PaginatedOrderResponseModel> fetchOrders({
    required int page,
    String? status,
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
    String? orderId,
  }) {
    final q = <String, dynamic>{'page': page};
    if (status != null && status.isNotEmpty) q['status'] = status;
    if (sourceBranch != null && sourceBranch.isNotEmpty) {
      q['source_branch'] = sourceBranch;
    }
    if (destinationBranch != null && destinationBranch.isNotEmpty) {
      q['destination_branch'] = destinationBranch;
    }
    if (startDate != null && startDate.isNotEmpty) q['start_date'] = startDate;
    if (endDate != null && endDate.isNotEmpty) q['end_date'] = endDate;
    _logQueryParams(ApiEndpoints.orderList, q);

    return remoteCall(
      () => _dioClient.get(ApiEndpoints.orderList, queryParameters: q),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch orders',
            statusCode: response.statusCode,
          );
        }
        return PaginatedOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
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
  }) {
    final q = _pageFilters(
      page,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      receiverSearch: receiverSearch,
      minCharge: minCharge,
      maxCharge: maxCharge,
    );
    _logQueryParams(ApiEndpoints.vendorDeliveredList, q);

    return remoteCall(
      () => _dioClient.get(
        ApiEndpoints.vendorDeliveredList,
        queryParameters: q,
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch delivered orders',
            statusCode: response.statusCode,
          );
        }
        return PaginatedDeliveredOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
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
  }) {
    final q = _pageFilters(
      page,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      receiverSearch: receiverSearch,
      minCharge: minCharge,
      maxCharge: maxCharge,
    );
    _logQueryParams(ApiEndpoints.vendorPossibleRedirect, q);

    return remoteCall(
      () => _dioClient.get(
        ApiEndpoints.vendorPossibleRedirect,
        queryParameters: q,
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch possible redirect orders',
            statusCode: response.statusCode,
          );
        }
        return PaginatedPossibleRedirectOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
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
  }) {
    final q = _pageFilters(
      page,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      receiverSearch: receiverSearch,
      minCharge: minCharge,
      maxCharge: maxCharge,
    );
    _logQueryParams(ApiEndpoints.vendorReturnedOrders, q);

    return remoteCall(
      () => _dioClient.get(
        ApiEndpoints.vendorReturnedOrders,
        queryParameters: q,
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch returned orders',
            statusCode: response.statusCode,
          );
        }
        return PaginatedReturnedOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
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
  }) {
    final q = _pageFilters(
      page,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      receiverSearch: receiverSearch,
      minCharge: minCharge,
      maxCharge: maxCharge,
    );
    _logQueryParams(ApiEndpoints.vendorRtvList, q);

    return remoteCall(
      () => _dioClient.get(
        ApiEndpoints.vendorRtvList,
        queryParameters: q,
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch RTV orders',
            statusCode: response.statusCode,
          );
        }
        return PaginatedRtvOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
  }

  @override
  Future<void> createOrder({required CreateOrderRequestModel request}) {
    return remoteCall(
      () => _dioClient.post(
        ApiEndpoints.vendorCreateOrder,
        data: request.toJson(),
      ),
      (response) {
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw ServerException(
            'Failed to create order',
            statusCode: response.statusCode,
          );
        }
      },
    );
  }

  @override
  Future<OrderDetailModel> fetchOrderDetail({required int orderId}) {
    return remoteCall(
      () => _dioClient.get('${ApiEndpoints.orderDetail}/$orderId/'),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch order details',
            statusCode: response.statusCode,
          );
        }
        final data = response.data;
        final jsonData = data is Map<String, dynamic>
            ? (data['data'] as Map<String, dynamic>? ?? data)
            : data as Map<String, dynamic>;
        return OrderDetailModel.fromJson(jsonData);
      },
    );
  }

  @override
  Future<void> editOrder({
    required int orderId,
    required EditOrderRequestModel request,
  }) {
    return remoteCall(
      () => _dioClient.put(
        '${ApiEndpoints.editOrder}$orderId/',
        data: request.toJson(),
      ),
      (response) {
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw ServerException(
            'Failed to edit order',
            statusCode: response.statusCode,
          );
        }
      },
    );
  }

  @override
  Future<PaginatedOrderResponseModel> searchOrderId({String? orderId}) {
    final q = <String, dynamic>{};
    if (orderId != null && orderId.isNotEmpty) q['search'] = orderId;
    _logQueryParams(ApiEndpoints.orderList, q);

    return remoteCall(
      () => _dioClient.get(ApiEndpoints.orderList, queryParameters: q),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to search orders by ID',
            statusCode: response.statusCode,
          );
        }
        return PaginatedOrderResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
  }

  @override
  Future<WarehouseOrdersListEntity> fetchWareHouseList(String page) {
    return remoteCall(
      () => _dioClient.get(
        ApiEndpoints.warehouseOrderList,
        queryParameters: {'page': page},
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch warehouse orders',
            statusCode: response.statusCode,
          );
        }
        return WarehouseOrdersListModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
  }

  @override
  Future<PaginatedStaleOrdersResponseModel> fetchStaleOrders({
    required int page,
  }) {
    return remoteCall(
      () => _dioClient.get(
        ApiEndpoints.staleOrders,
        queryParameters: {'page': page},
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch stale orders',
            statusCode: response.statusCode,
          );
        }
        return PaginatedStaleOrdersResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
  }

  @override
  Future<RedirectedOrders> fetchRedirectedOrders({required int page}) {
    return remoteCall(
      () => _dioClient.get(
        ApiEndpoints.redirectedOrders,
        queryParameters: {'page': page},
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch redirected orders',
            statusCode: response.statusCode,
          );
        }
        return RedirectedOrdersModel.fromJson(
          response.data as Map<String, dynamic>,
        ).toEntity();
      },
    );
  }

  @override
  Future<TodayRedirectOrderList> fetchRedirectedOrdersToday({
    required int page,
  }) {
    return remoteCall(
      () => _dioClient.get(
        ApiEndpoints.redirectedOrdersToday,
        queryParameters: {'page': page},
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            "Failed to fetch today's redirected orders",
            statusCode: response.statusCode,
          );
        }
        return TodayRedirectOrderListModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      },
    );
  }
}
