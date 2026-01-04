import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'returned_order_model.g.dart';

@JsonSerializable()
class ReturnedOrderModel extends ReturnedOrderEntity {
  const ReturnedOrderModel({
    required super.orderId,
    required super.codCharge,
    required super.destination,
    required super.receiver,
    required super.deliveryCharge,
    required super.deliveredDate,
    required super.receiverNumber,
  });

  @override
  @JsonKey(name: 'order_id')
  int get orderId => super.orderId;

  @override
  @JsonKey(name: 'cod_charge')
  String get codCharge => super.codCharge;

  @override
  String get destination => super.destination;

  @override
  String get receiver => super.receiver;

  @override
  @JsonKey(name: 'delivery_charge')
  String get deliveryCharge => super.deliveryCharge;

  @override
  @JsonKey(name: 'delivered_date')
  String get deliveredDate => super.deliveredDate;

  @override
  @JsonKey(name: 'receiver_number')
  String get receiverNumber => super.receiverNumber;

  factory ReturnedOrderModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnedOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReturnedOrderModelToJson(this);
}
