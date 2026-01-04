import 'package:gaaubesi_vendor/features/orders/data/models/rtv_order_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_rtv_order_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paginated_rtv_order_response_model.g.dart';

@JsonSerializable()
class PaginatedRtvOrderResponseModel extends PaginatedRtvOrderResponseEntity {
  const PaginatedRtvOrderResponseModel({
    required super.count,
    required super.totalPages,
    super.next,
    super.previous,
    required List<RtvOrderModel> super.results,
  });

  @override
  @JsonKey(name: 'total_pages')
  int get totalPages => super.totalPages;

  @override
  List<RtvOrderModel> get results => super.results as List<RtvOrderModel>;

  factory PaginatedRtvOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaginatedRtvOrderResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedRtvOrderResponseModelToJson(this);
}
