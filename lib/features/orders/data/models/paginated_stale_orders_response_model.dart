// ignore_for_file: non_constant_identifier_names

import 'package:gaaubesi_vendor/features/orders/data/models/stale_orders_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/paginated_stale_orders_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'paginated_stale_orders_response_model.g.dart';

@JsonSerializable()
class PaginatedStaleOrdersResponseModel {
  final List<StaleOrdersListModel> results;
  final int count;
  @JsonKey(defaultValue: false)
  final bool has_more;

  PaginatedStaleOrdersResponseModel({
    required this.results,
    required this.count,
    required this.has_more,
  });

  /// JSON serialization
  factory PaginatedStaleOrdersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaginatedStaleOrdersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedStaleOrdersResponseModelToJson(this);

  /// Convert model to entity
  PaginatedStaleOrdersResponseEntity toEntity() {
    return PaginatedStaleOrdersResponseEntity(
      results: results.map((model) => model.toEntity()).toList(),
      count: count,
      hasMore: has_more,
    );
  }
}
