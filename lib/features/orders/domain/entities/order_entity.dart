import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final int orderId;
  final String orderIdWithStatus;
  final String deliveredDate;
  final String receiverName;
  final String receiverNumber;
  final String? altReceiverNumber;
  final String receiverAddress;
  final String deliveryCharge;
  final String codCharge;
  final String lastDeliveryStatus;
  final String source;
  final String destination;
  final String desc;

  const OrderEntity({
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
  });

  @override
  List<Object?> get props => [
        orderId,
        orderIdWithStatus,
        deliveredDate,
        receiverName,
        receiverNumber,
        altReceiverNumber,
        receiverAddress,
        deliveryCharge,
        codCharge,
        lastDeliveryStatus,
        source,
        destination,
        desc,
      ];
}
