import 'package:equatable/equatable.dart';

class DeliveredOrderEntity extends Equatable {
  final String orderId;
  final String codCharge;
  final String destination;
  final String receiverNumber;
  final String receiverName;
  final String deliveryCharge;
  final String deliveredDate;
  final String createdOn;

  const DeliveredOrderEntity({
    required this.orderId,
    required this.codCharge,
    required this.destination,
    required this.receiverNumber,
    required this.receiverName,
    required this.deliveryCharge,
    required this.deliveredDate,
    required this.createdOn,
  });

  @override
  List<Object?> get props => [
        orderId,
        codCharge,
        destination,
        receiverNumber,
        receiverName,
        deliveryCharge,
        deliveredDate,
        createdOn,
      ];
}
