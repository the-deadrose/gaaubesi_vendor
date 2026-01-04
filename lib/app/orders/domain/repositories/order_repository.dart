import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/paginated_order_response_entity.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/paginated_delivered_order_response_entity.dart';

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
  });
}
