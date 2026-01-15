import 'package:equatable/equatable.dart';

class ReturnedOrderEntity extends Equatable {
  final String orderId;
  final String detailUrl;
  final String source;
  final String destination;
  final String receiverAddress;
  final String codCharge;
  final String customerName;
  final String customerNumber;

  const ReturnedOrderEntity({
    required this.orderId,
    required this.detailUrl,
    required this.source,
    required this.destination,
    required this.receiverAddress,
    required this.codCharge,
    required this.customerName,
    required this.customerNumber,
  });

  @override
  List<Object?> get props => [
        orderId,
        detailUrl,
        source,
        destination,
        receiverAddress,
        codCharge,
        customerName,
        customerNumber,
      ];
}
