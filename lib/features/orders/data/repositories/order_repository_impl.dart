import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import 'package:gaaubesi_vendor/core/data/failure_mapper.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/create_order_request_model.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/edit_order_request_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/create_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/edit_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_delivered_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_possible_redirect_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_returned_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_rtv_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_stale_orders_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/today_redirect_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/ware_house_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } catch (e) {
      return Left(toFailure(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedOrderResponseEntity>> fetchOrders({
    required int page,
    String? status,
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
  }) =>
      _guard(() => remoteDataSource.fetchOrders(
            page: page,
            status: status,
            sourceBranch: sourceBranch,
            destinationBranch: destinationBranch,
            startDate: startDate,
            endDate: endDate,
          ));

  @override
  Future<Either<Failure, PaginatedDeliveredOrderResponseEntity>>
      fetchDeliveredOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) =>
          _guard(() => remoteDataSource.fetchDeliveredOrders(
                page: page,
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                receiverSearch: receiverSearch,
                minCharge: minCharge,
                maxCharge: maxCharge,
              ));

  @override
  Future<Either<Failure, PaginatedPossibleRedirectOrderResponseEntity>>
      fetchPossibleRedirectOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) =>
          _guard(() => remoteDataSource.fetchPossibleRedirectOrders(
                page: page,
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                receiverSearch: receiverSearch,
                minCharge: minCharge,
                maxCharge: maxCharge,
              ));

  @override
  Future<Either<Failure, PaginatedReturnedOrderResponseEntity>>
      fetchReturnedOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) =>
          _guard(() => remoteDataSource.fetchReturnedOrders(
                page: page,
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                receiverSearch: receiverSearch,
                minCharge: minCharge,
                maxCharge: maxCharge,
              ));

  @override
  Future<Either<Failure, PaginatedRtvOrderResponseEntity>> fetchRtvOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) =>
      _guard(() => remoteDataSource.fetchRtvOrders(
            page: page,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            receiverSearch: receiverSearch,
            minCharge: minCharge,
            maxCharge: maxCharge,
          ));

  @override
  Future<Either<Failure, void>> createOrder({
    required CreateOrderRequestEntity request,
  }) =>
      _guard(() async {
        final model = CreateOrderRequestModel(
          branch: request.branch,
          destinationBranch: request.destinationBranch,
          receiverName: request.receiverName,
          receiverPhoneNumber: request.receiverPhoneNumber,
          altReceiverPhoneNumber: request.altReceiverPhoneNumber,
          receiverFullAddress: request.receiverFullAddress,
          codCharge: request.codCharge,
          packageAccess: request.packageAccess,
          referenceId: request.referenceId,
          pickupPoint: request.pickupPoint,
          pickupType: request.pickupType,
          packageType: request.packageType,
          remarks: request.remarks,
        );
        await remoteDataSource.createOrder(request: model);
      });

  @override
  Future<Either<Failure, OrderDetailEntity>> fetchOrderDetail({
    required int orderId,
  }) =>
      _guard(() => remoteDataSource.fetchOrderDetail(orderId: orderId));

  @override
  Future<Either<Failure, void>> editOrder({
    required int orderId,
    required OrderEditEntity request,
  }) =>
      _guard(() async {
        final model = EditOrderRequestModel(
          branch: request.branch,
          destinationBranch: request.destinationBranch,
          weight: request.weight,
          codCharge: request.codCharge,
          packageAccess: request.packageAccess,
          packageType: request.packageType,
          remarks: request.remarks,
          receiverName: request.receiverName,
          receiverPhoneNumber: request.receiverPhoneNumber,
          pickupType: request.pickupType,
          altReceiverPhoneNumber: request.altReceiverPhoneNumber,
          receiverFullAddress: request.receiverFullAddress,
        );
        await remoteDataSource.editOrder(orderId: orderId, request: model);
      });

  @override
  Future<Either<Failure, List<OrderEntity>>> searchOrders({
    required String query,
    int? limit,
  }) =>
      _guard(() async {
        final result = await remoteDataSource.searchOrderId(orderId: query);
        final orders = result.results;
        return limit != null && orders.length > limit
            ? orders.sublist(0, limit)
            : orders;
      });

  @override
  Future<Either<Failure, WarehouseOrdersListEntity>> wareHouseList({
    required String page,
  }) =>
      _guard(() => remoteDataSource.fetchWareHouseList(page));

  @override
  Future<Either<Failure, PaginatedStaleOrdersResponseEntity>> fetchStaleOrders({
    required int page,
  }) =>
      _guard(() async {
        final result = await remoteDataSource.fetchStaleOrders(page: page);
        return result.toEntity();
      });

  @override
  Future<Either<Failure, RedirectedOrders>> fetchRedirectedOrders({
    required int page,
  }) =>
      _guard(() => remoteDataSource.fetchRedirectedOrders(page: page));

  @override
  Future<Either<Failure, TodayRedirectOrderList>> fetchRedirectedOrdersToday({
    required int page,
  }) =>
      _guard(
          () => remoteDataSource.fetchRedirectedOrdersToday(page: page));
}
