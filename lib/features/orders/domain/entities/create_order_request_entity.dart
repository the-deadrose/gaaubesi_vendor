import 'package:equatable/equatable.dart';

class CreateOrderRequestEntity extends Equatable {
  final String branch;
  final String destinationBranch;
  final String receiverName;
  final String receiverPhoneNumber;
  final String? altReceiverPhoneNumber;
  final String receiverFullAddress;
  final double weight;
  final double deliveryCharge;
  final double codCharge;
  final String packageAccess;
  final String? referenceId;
  final String? pickupPoint;
  final String pickupType;
  final String packageType;
  final String? remarks;

  const CreateOrderRequestEntity({
    required this.branch,
    required this.destinationBranch,
    required this.receiverName,
    required this.receiverPhoneNumber,
    this.altReceiverPhoneNumber,
    required this.receiverFullAddress,
    required this.weight,
    required this.deliveryCharge,
    required this.codCharge,
    required this.packageAccess,
    this.referenceId,
    this.pickupPoint,
    required this.pickupType,
    required this.packageType,
    this.remarks,
  });

  @override
  List<Object?> get props => [
    branch,
    destinationBranch,
    receiverName,
    receiverPhoneNumber,
    altReceiverPhoneNumber,
    receiverFullAddress,
    weight,
    deliveryCharge,
    codCharge,
    packageAccess,
    referenceId,
    pickupPoint,
    pickupType,
    packageType,
    remarks,
  ];
}
