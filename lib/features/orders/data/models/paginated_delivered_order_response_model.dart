import 'package:gaaubesi_vendor/features/orders/data/models/delivered_order_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_delivered_order_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paginated_delivered_order_response_model.g.dart';

@JsonSerializable()
class PaginatedDeliveredOrderResponseModel
    extends PaginatedDeliveredOrderResponseEntity {
  const PaginatedDeliveredOrderResponseModel({
    required super.count,
    required super.totalPages,
    super.next,
    super.previous,
    required List<DeliveredOrderModel> super.results,
  });

  @override
  @JsonKey(name: 'total_pages')
  int get totalPages => super.totalPages;

  @override
  List<DeliveredOrderModel> get results =>
      super.results as List<DeliveredOrderModel>;

  factory PaginatedDeliveredOrderResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    // Handle links object if present
    final links = json['links'] as Map<String, dynamic>?;
    return PaginatedDeliveredOrderResponseModel(
      count: json['count'] as int,
      totalPages: json['total_pages'] as int,
      next: links?['next'] as String?,
      previous: links?['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => DeliveredOrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() =>
      _$PaginatedDeliveredOrderResponseModelToJson(this);
}
