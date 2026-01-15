import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_delivered_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_possible_redirect_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_returned_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_rtv_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/create_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/edit_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/ware_house_orders_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, PaginatedOrderResponseEntity>> fetchOrders({
    required int page,
    String? status,
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
  });

  Future<Either<Failure, PaginatedDeliveredOrderResponseEntity>>
  fetchDeliveredOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  });

  Future<Either<Failure, PaginatedPossibleRedirectOrderResponseEntity>>
  fetchPossibleRedirectOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  });

  Future<Either<Failure, PaginatedReturnedOrderResponseEntity>>
  fetchReturnedOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  });

  Future<Either<Failure, PaginatedRtvOrderResponseEntity>> fetchRtvOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  });

  Future<Either<Failure, void>> createOrder({
    required CreateOrderRequestEntity request,
  });

  Future<Either<Failure, OrderDetailEntity>> fetchOrderDetail({
    required int orderId,
  });

  Future<Either<Failure, void>> editOrder({
    required int orderId,
    required OrderEditEntity request,
  });

  Future<Either<Failure, List<OrderEntity>>> searchOrders({
    required String query,
    int? limit,
  });

  Future<Either<Failure, WareHouseOrdersEntity>> wareHouseList({
    required String page,
  });
}
