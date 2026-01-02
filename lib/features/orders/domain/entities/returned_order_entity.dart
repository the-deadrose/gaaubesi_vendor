import 'package:equatable/equatable.dart';

class ReturnedOrderEntity extends Equatable {
  final int orderId;
  final String codCharge;
  final String destination;
  final String receiver;
  final String deliveryCharge;
  final String deliveredDate;
  final String receiverNumber;

  const ReturnedOrderEntity({
    required this.orderId,
    required this.codCharge,
    required this.destination,
    required this.receiver,
    required this.deliveryCharge,
    required this.deliveredDate,
    required this.receiverNumber,
  });

  @override
  List<Object?> get props => [
    orderId,
    codCharge,
    destination,
    receiver,
    deliveryCharge,
    deliveredDate,
    receiverNumber,
  ];
}
