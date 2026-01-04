import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.orderIdWithStatus,
    super.deliveredDate,
    required super.receiverName,
    required super.receiverNumber,
    super.altReceiverNumber,
    required super.receiverAddress,
    required super.deliveryCharge,
    required super.codCharge,
    required super.lastDeliveryStatus,
    required super.source,
    required super.destination,
    required super.description,
  });

  @override
  @JsonKey(name: 'order_id')
  int get orderId => super.orderId;

  @override
  @JsonKey(name: 'order_id_w_status')
  String get orderIdWithStatus => super.orderIdWithStatus;

  @override
  @JsonKey(name: 'delivered_date')
  String? get deliveredDate => super.deliveredDate;

  @override
  @JsonKey(name: 'receiver_name')
  String get receiverName => super.receiverName;

  @override
  @JsonKey(name: 'receiver_number')
  String get receiverNumber => super.receiverNumber;

  @override
  @JsonKey(name: 'alt_receiver_number')
  String? get altReceiverNumber => super.altReceiverNumber;

  @override
  @JsonKey(name: 'receiver_address')
  String get receiverAddress => super.receiverAddress;

  @override
  @JsonKey(name: 'delivery_charge')
  String get deliveryCharge => super.deliveryCharge;

  @override
  @JsonKey(name: 'cod_charge')
  String get codCharge => super.codCharge;

  @override
  @JsonKey(name: 'last_delivery_status')
  String get lastDeliveryStatus => super.lastDeliveryStatus;



  @override
  @JsonKey(name: 'desc')
  String get description => super.description;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
