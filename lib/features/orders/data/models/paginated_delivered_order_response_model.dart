import 'package:gaaubesi_vendor/features/orders/data/models/delivered_order_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/delivered_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_delivered_order_response_entity.dart';

class PaginatedDeliveredOrderResponseModel
    extends PaginatedDeliveredOrderResponseEntity {
  const PaginatedDeliveredOrderResponseModel({
    required super.count,
    required super.totalPages,
    super.next,
    super.previous,
    required super.results,
  });

  factory PaginatedDeliveredOrderResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaginatedDeliveredOrderResponseModel(
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: List<DeliveredOrderEntity>.from(
        ((json['results'] as List<dynamic>?) ?? []).map(
          (e) => DeliveredOrderModel.fromJson(e as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'total_pages': totalPages,
      'next': next,
      'previous': previous,
      'results': results
          .map((e) => (e as DeliveredOrderModel).toJson())
          .toList(),
    };
  }
}
