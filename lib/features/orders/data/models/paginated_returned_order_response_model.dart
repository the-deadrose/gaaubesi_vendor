import 'package:gaaubesi_vendor/features/orders/data/models/returned_order_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_returned_order_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paginated_returned_order_response_model.g.dart';

@JsonSerializable()
class PaginatedReturnedOrderResponseModel
    extends PaginatedReturnedOrderResponseEntity {
  @override
  @JsonKey(defaultValue: 0)
  final int count;

  @override
  @JsonKey(name: 'total_pages', defaultValue: 0)
  final int totalPages;

  const PaginatedReturnedOrderResponseModel({
    required this.count,
    required this.totalPages,
    super.next,
    super.previous,
    required List<ReturnedOrderModel> super.results,
  }) : super(count: count, totalPages: totalPages);

  @override
  List<ReturnedOrderModel> get results =>
      super.results as List<ReturnedOrderModel>;

  factory PaginatedReturnedOrderResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$PaginatedReturnedOrderResponseModelFromJson(json);
  Map<String, dynamic> toJson() =>
      _$PaginatedReturnedOrderResponseModelToJson(this);
}
