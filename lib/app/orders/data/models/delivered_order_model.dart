import 'package:gaaubesi_vendor/app/orders/domain/entities/delivered_order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivered_order_model.g.dart';

@JsonSerializable()
class DeliveredOrderModel extends DeliveredOrderEntity {
  const DeliveredOrderModel({
    required super.orderId,
    required super.codCharge,
    required super.destination,
    required super.receiverNumber,
    required super.receiverName,
    required super.deliveryCharge,
    required super.deliveredDate,
    required super.createdOn,
  });

  @override
  @JsonKey(name: 'order_id')
  String get orderId => super.orderId;

  @override
  @JsonKey(name: 'cod_charge')
  String get codCharge => super.codCharge;

  @override
  String get destination => super.destination;

  @override
  @JsonKey(name: 'receiver_number')
  String get receiverNumber => super.receiverNumber;

  @override
  @JsonKey(name: 'receiver_name')
  String get receiverName => super.receiverName;

  @override
  @JsonKey(name: 'delivery_charge')
  String get deliveryCharge => super.deliveryCharge;

  @override
  @JsonKey(name: 'delivered_date')
  String get deliveredDate => super.deliveredDate;

  @override
  @JsonKey(name: 'created_on')
  String get createdOn => super.createdOn;

  factory DeliveredOrderModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveredOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveredOrderModelToJson(this);
}
