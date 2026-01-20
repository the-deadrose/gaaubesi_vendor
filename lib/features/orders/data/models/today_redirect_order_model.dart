import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/today_redirect_order_entity.dart';

part 'today_redirect_order_model.g.dart';

double _doubleFromJson(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

String _stringFromJson(dynamic value) => value?.toString() ?? '';

DateTime _dateTimeFromJson(dynamic value) {
  if (value == null || value.toString().isEmpty) return DateTime.now();
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}

List<TodayRedirectOrderModel> _orderListFromJson(dynamic json) {
  if (json == null) return <TodayRedirectOrderModel>[];
  if (json is! List) return <TodayRedirectOrderModel>[];
  return json
      .map((e) =>
          TodayRedirectOrderModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// -------------------------------
/// Today Redirect Order Model
/// -------------------------------
@JsonSerializable()
class TodayRedirectOrderModel extends TodayRedirectOrder {
  @JsonKey(name: 'parent_order_id', fromJson: _stringFromJson)
  final String parentOrderId;

  @JsonKey(name: 'child_order_id')
  final int childOrderId;

  @JsonKey(name: 'child_order_status', fromJson: _stringFromJson)
  final String childOrderStatus;

  @JsonKey(name: 'child_cod_charge', fromJson: _doubleFromJson)
  final double childCodCharge;

  @JsonKey(name: 'parent_delivery_charge', fromJson: _stringFromJson)
  final String parentDeliveryCharge;

  @JsonKey(name: 'child_delivery_charge', fromJson: _doubleFromJson)
  final double childDeliveryCharge;

  @JsonKey(name: 'created_on', fromJson: _dateTimeFromJson)
  final DateTime createdOn;

  const TodayRedirectOrderModel({
    required this.parentOrderId,
    required this.childOrderId,
    required this.childOrderStatus,
    required this.childCodCharge,
    required this.parentDeliveryCharge,
    required this.childDeliveryCharge,
    required this.createdOn,
  }) : super(
          parentOrderId: parentOrderId,
          childOrderId: childOrderId,
          childOrderStatus: childOrderStatus,
          childCodCharge: childCodCharge,
          parentDeliveryCharge: parentDeliveryCharge,
          childDeliveryCharge: childDeliveryCharge,
          createdOn: createdOn,
        );

  factory TodayRedirectOrderModel.fromJson(Map<String, dynamic> json) =>
      _$TodayRedirectOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodayRedirectOrderModelToJson(this);
}

/// -------------------------------
/// Today Redirect Order List Model
/// -------------------------------
@JsonSerializable()
class TodayRedirectOrderListModel extends TodayRedirectOrderList {
  @JsonKey(fromJson: _orderListFromJson)
  final List<TodayRedirectOrderModel> results;

  @JsonKey(name: 'count', defaultValue: 0)
  final int count;

  @JsonKey(name: 'next', fromJson: _stringFromJson, defaultValue: null)
  final String? next;

  @JsonKey(name: 'previous', fromJson: _stringFromJson, defaultValue: null)
  final String? previous;

  const TodayRedirectOrderListModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  }) : super(
          count: count,
          next: next,
          previous: previous,
          results: results,
        );

  factory TodayRedirectOrderListModel.fromJson(Map<String, dynamic> json) =>
      _$TodayRedirectOrderListModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodayRedirectOrderListModelToJson(this);
}
