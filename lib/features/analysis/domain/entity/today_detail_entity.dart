import 'package:equatable/equatable.dart';

class TodayDetailEntity extends Equatable {
  final int sN;
  final int orderId;
  final String sourceBranch;
  final String destinationBranch;
  final String receiverName;
  final String receiverAddress;
  final String deliveryCharge;
  final String cod;
  final DateTime createdAt;
  final String lastDeliveryStatus;

  const TodayDetailEntity({
    required this.sN,
    required this.orderId,
    required this.sourceBranch,
    required this.destinationBranch,
    required this.receiverName,
    required this.receiverAddress,
    required this.deliveryCharge,
    required this.cod,
    required this.createdAt,
    required this.lastDeliveryStatus,
  });

  @override
  List<Object?> get props => [
        sN,
        orderId,
        sourceBranch,
        destinationBranch,
        receiverName,
        receiverAddress,
        deliveryCharge,
        cod,
        createdAt,
        lastDeliveryStatus,
      ];
}
