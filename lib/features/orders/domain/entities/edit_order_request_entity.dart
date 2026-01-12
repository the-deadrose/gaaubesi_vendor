import 'package:equatable/equatable.dart';

class OrderEditEntity extends Equatable {
  final int branch;
  final int destinationBranch;
  final double weight;
  final int codCharge;
  final String packageAccess;
  final String packageType;
  final String remarks;
  final String receiverName;
  final String receiverPhoneNumber;
  final String pickupType;
  final String altReceiverPhoneNumber;
  final String receiverFullAddress;

  const OrderEditEntity({
    required this.branch,
    required this.destinationBranch,
    required this.weight,
    required this.codCharge,
    required this.packageAccess,
    required this.packageType,
    required this.remarks,
    required this.receiverName,
    required this.receiverPhoneNumber,
    required this.pickupType,
    required this.altReceiverPhoneNumber,
    required this.receiverFullAddress,
  });

  @override
  List<Object?> get props => [
        branch,
        destinationBranch,
        weight,
        codCharge,
        packageAccess,
        packageType,
        remarks,
        receiverName,
        receiverPhoneNumber,
        pickupType,
        altReceiverPhoneNumber,
        receiverFullAddress,
      ];
}
