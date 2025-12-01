import 'package:gaaubesi_vendor/features/orders/data/models/order_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_order_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paginated_order_response_model.g.dart';

@JsonSerializable()
class PaginatedOrderResponseModel extends PaginatedOrderResponseEntity {
  const PaginatedOrderResponseModel({
    required super.count,
    super.next,
    super.previous,
    required List<OrderModel> super.results,
  });

  @override
  List<OrderModel> get results => super.results as List<OrderModel>;

  factory PaginatedOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaginatedOrderResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedOrderResponseModelToJson(this);
}
