import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'redirected_orders_model.g.dart';



int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

String _stringFromJson(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
  return DateTime.tryParse(value.toString()) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

List<RedirectedOrderItemModel> _redirectedOrderListFromJson(dynamic json) {
  if (json == null) return const [];
  if (json is! List) return const [];

  return json
      .where((e) => e != null)
      .map(
        (e) => RedirectedOrderItemModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList();
}



@JsonSerializable()
class RedirectedOrdersModel {
  @JsonKey(fromJson: _intFromJson, defaultValue: 0)
  final int count;

  @JsonKey(fromJson: _stringFromJson, defaultValue: '')
  final String next;

  @JsonKey(fromJson: _stringFromJson, defaultValue: '')
  final String previous;

  @JsonKey(fromJson: _redirectedOrderListFromJson, defaultValue: [])
  final List<RedirectedOrderItemModel> results;

  const RedirectedOrdersModel({
    this.count = 0,
    this.next = '',
    this.previous = '',
    this.results = const [],
  });

  factory RedirectedOrdersModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RedirectedOrdersModel();
    }
    return _$RedirectedOrdersModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RedirectedOrdersModelToJson(this);

  RedirectedOrders toEntity() {
    return RedirectedOrders(
      count: count,
      next: next,
      previous: previous,
      results: results.map((e) => e.toEntity()).toList(),
    );
  }
}



@JsonSerializable()
class RedirectedOrderItemModel {
  @JsonKey(name: 'parent_order_id', fromJson: _stringFromJson, defaultValue: '')
  final String parentOrderId;

  @JsonKey(name: 'child_order_id', fromJson: _intFromJson, defaultValue: 0)
  final int childOrderId;

  @JsonKey(
    name: 'child_order_status',
    fromJson: _stringFromJson,
    defaultValue: '',
  )
  final String childOrderStatus;

  @JsonKey(name: 'vendor_name', fromJson: _stringFromJson, defaultValue: '')
  final String vendorName;

  @JsonKey(
    name: 'created_on',
    fromJson: _dateTimeFromJson,
  )
  final DateTime createdOn;

   RedirectedOrderItemModel({
    this.parentOrderId = '',
    this.childOrderId = 0,
    this.childOrderStatus = '',
    this.vendorName = '',
    DateTime? createdOn,
  }) : createdOn =
            createdOn ??  DateTime.fromMillisecondsSinceEpoch(0);

  factory RedirectedOrderItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return  RedirectedOrderItemModel();
    }
    return _$RedirectedOrderItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() =>
      _$RedirectedOrderItemModelToJson(this);

  RedirectedOrderItem toEntity() {
    return RedirectedOrderItem(
      parentOrderId: parentOrderId,
      childOrderId: childOrderId,
      childOrderStatus: childOrderStatus,
      vendorName: vendorName,
      createdOn: createdOn,
    );
  }
}
