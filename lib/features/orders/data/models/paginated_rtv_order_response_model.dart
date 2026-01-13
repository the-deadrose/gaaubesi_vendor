import 'package:gaaubesi_vendor/features/orders/data/models/rtv_order_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_rtv_order_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paginated_rtv_order_response_model.g.dart';

@JsonSerializable()
class PaginatedRtvOrderResponseModel extends PaginatedRtvOrderResponseEntity {
  @override
  @JsonKey(defaultValue: 0)
  final int count;

  @override
  @JsonKey(name: 'total_pages', defaultValue: 0)
  final int totalPages;

  const PaginatedRtvOrderResponseModel({
    required this.count,
    required this.totalPages,
    super.next,
    super.previous,
    required List<RtvOrderModel> super.results,
  }) : super(count: count, totalPages: totalPages);

  @override
  List<RtvOrderModel> get results => super.results as List<RtvOrderModel>;

  factory PaginatedRtvOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaginatedRtvOrderResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedRtvOrderResponseModelToJson(this);
}
