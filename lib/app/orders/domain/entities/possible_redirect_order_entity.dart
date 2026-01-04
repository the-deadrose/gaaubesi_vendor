import 'package:equatable/equatable.dart';

class PossibleRedirectOrderEntity extends Equatable {
  final String orderId;
  final String codCharge;
  final String destination;
  final String createdOn;
  final String receiver;
  final String deliveryCharge;

  const PossibleRedirectOrderEntity({
    required this.orderId,
    required this.codCharge,
    required this.destination,
    required this.createdOn,
    required this.receiver,
    required this.deliveryCharge,
  });

  @override
  List<Object?> get props => [
    orderId,
    codCharge,
    destination,
    createdOn,
    receiver,
    deliveryCharge,
  ];
}
