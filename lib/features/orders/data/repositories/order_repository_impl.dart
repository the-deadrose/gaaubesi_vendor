import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/create_order_request_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_delivered_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_possible_redirect_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_returned_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_rtv_order_response_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/create_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedOrderResponseEntity>> fetchOrders({
    required int page,
    String? status,
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final result = await remoteDataSource.fetchOrders(
        page: page,
        status: status,
        sourceBranch: sourceBranch,
        destinationBranch: destinationBranch,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

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
  }) async {
    try {
      final result = await remoteDataSource.fetchDeliveredOrders(
        page: page,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        receiverSearch: receiverSearch,
        minCharge: minCharge,
        maxCharge: maxCharge,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

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
  }) async {
    // try {
    final result = await remoteDataSource.fetchPossibleRedirectOrders(
      page: page,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      receiverSearch: receiverSearch,
      minCharge: minCharge,
      maxCharge: maxCharge,
    );
    return Right(result);
    // } on ServerException catch (e) {
    //   return Left(ServerFailure(e.message, statusCode: e.statusCode));
    // } on NetworkException catch (e) {
    //   return Left(NetworkFailure(e.message));
    // } catch (e) {
    //   return Left(ServerFailure(e.toString()));
    // }
  }

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
  }) async {
    try {
      final result = await remoteDataSource.fetchReturnedOrders(
        page: page,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        receiverSearch: receiverSearch,
        minCharge: minCharge,
        maxCharge: maxCharge,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedRtvOrderResponseEntity>> fetchRtvOrders({
    required int page,
    String? destination,
    String? startDate,
    String? endDate,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
  }) async {
    try {
      final result = await remoteDataSource.fetchRtvOrders(
        page: page,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        receiverSearch: receiverSearch,
        minCharge: minCharge,
        maxCharge: maxCharge,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createOrder({
    required CreateOrderRequestEntity request,
  }) async {
    try {
      final model = CreateOrderRequestModel(
        branch: request.branch,
        destinationBranch: request.destinationBranch,
        receiverName: request.receiverName,
        receiverPhoneNumber: request.receiverPhoneNumber,
        altReceiverPhoneNumber: request.altReceiverPhoneNumber,
        receiverFullAddress: request.receiverFullAddress,
        weight: request.weight,
        deliveryCharge: request.deliveryCharge,
        codCharge: request.codCharge,
        packageAccess: request.packageAccess,
        referenceId: request.referenceId,
        pickupPoint: request.pickupPoint,
        pickupType: request.pickupType,
        packageType: request.packageType,
        remarks: request.remarks,
      );
      await remoteDataSource.createOrder(request: model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> fetchOrderDetail({
    required int orderId,
  }) async {
    try {
      final result = await remoteDataSource.fetchOrderDetail(orderId: orderId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
