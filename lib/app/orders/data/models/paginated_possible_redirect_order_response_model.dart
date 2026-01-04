import 'package:gaaubesi_vendor/features/orders/data/models/possible_redirect_order_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_possible_redirect_order_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paginated_possible_redirect_order_response_model.g.dart';

@JsonSerializable()
class PaginatedPossibleRedirectOrderResponseModel
    extends PaginatedPossibleRedirectOrderResponseEntity {
  const PaginatedPossibleRedirectOrderResponseModel({
    required super.totalPages,
    super.next,
    super.previous,
    required List<PossibleRedirectOrderModel> super.results,
  });

  @override
  @JsonKey(name: 'total_pages')
  int get totalPages => super.totalPages;

  @override
  List<PossibleRedirectOrderModel> get results =>
      super.results as List<PossibleRedirectOrderModel>;

  factory PaginatedPossibleRedirectOrderResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$PaginatedPossibleRedirectOrderResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PaginatedPossibleRedirectOrderResponseModelToJson(this);
}
