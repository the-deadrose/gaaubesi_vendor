import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderModel extends OrderEntity {
  @JsonKey(required: true)
  @override
  final int orderId;
  
  @JsonKey(name: 'order_id_w_status', required: true)
  @override
  final String orderIdWithStatus;
  
  @JsonKey(required: false, defaultValue: '')
  @override
  final String deliveredDate;
  
  @JsonKey(required: true)
  @override
  final String receiverName;
  
  @JsonKey(required: true)
  @override
  final String receiverNumber;
  
  @JsonKey(required: false)
  @override
  final String? altReceiverNumber;
  
  @JsonKey(required: true)
  @override
  final String receiverAddress;
  
  @JsonKey(name: 'delivery_charge', required: false, defaultValue: '')
  @override
  final String deliveryCharge;
  
  @JsonKey(required: true)
  @override
  final String codCharge;
  
  @JsonKey(required: true)
  @override
  final String lastDeliveryStatus;
  
  @JsonKey(required: true)
  @override
  final String source;
  
  @JsonKey(required: true)
  @override
  final String destination;
  
  @JsonKey(required: true)
  @override
  final String desc;

  const OrderModel({
    required this.orderId,
    required this.orderIdWithStatus,
    required this.deliveredDate,
    required this.receiverName,
    required this.receiverNumber,
    this.altReceiverNumber,
    required this.receiverAddress,
    required this.deliveryCharge,
    required this.codCharge,
    required this.lastDeliveryStatus,
    required this.source,
    required this.destination,
    required this.desc,
  }) : super(
          orderId: orderId,
          orderIdWithStatus: orderIdWithStatus,
          deliveredDate: deliveredDate,
          receiverName: receiverName,
          receiverNumber: receiverNumber,
          altReceiverNumber: altReceiverNumber,
          receiverAddress: receiverAddress,
          deliveryCharge: deliveryCharge,
          codCharge: codCharge,
          lastDeliveryStatus: lastDeliveryStatus,
          source: source,
          destination: destination,
          desc: desc,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle the typo in the API: delivery_change instead of delivery_charge
    if (json.containsKey('delivery_change') && !json.containsKey('delivery_charge')) {
      json['delivery_charge'] = json['delivery_change'];
    }
    return _$OrderModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
