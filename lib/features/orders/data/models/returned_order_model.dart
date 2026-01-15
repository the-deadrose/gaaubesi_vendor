import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_order_entity.dart';

part 'returned_order_model.g.dart';

@JsonSerializable()
class ReturnedOrderModel extends ReturnedOrderEntity {
  @JsonKey(name: 'order_id', defaultValue: '')
  final String orderId;
  
  @JsonKey(name: 'detail_url', defaultValue: '')
  final String detailUrl;
  
  @JsonKey(name: 'source', defaultValue: '')
  final String source;
  
  @JsonKey(name: 'destination', defaultValue: '')
  final String destination;
  
  @JsonKey(name: 'receiver_address', defaultValue: '')
  final String receiverAddress;
  
  @JsonKey(name: 'cod_charge', defaultValue: '')
  final String codCharge;
  
  @JsonKey(name: 'customer_name', defaultValue: '')
  final String customerName;
  
  @JsonKey(name: 'customer_number', defaultValue: '')
  final String customerNumber;

  const ReturnedOrderModel({
    required this.orderId,
    required this.detailUrl,
    required this.source,
    required this.destination,
    required this.receiverAddress,
    required this.codCharge,
    required this.customerName,
    required this.customerNumber,
  }) : super(
          orderId: orderId,
          detailUrl: detailUrl,
          source: source,
          destination: destination,
          receiverAddress: receiverAddress,
          codCharge: codCharge,
          customerName: customerName,
          customerNumber: customerNumber,
        );

  factory ReturnedOrderModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnedOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReturnedOrderModelToJson(this);
}
