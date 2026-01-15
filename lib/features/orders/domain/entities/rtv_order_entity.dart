import 'package:equatable/equatable.dart';

class RtvOrderEntity extends Equatable {
  final String orderId;
  final int id;
  final String destinationBranch;
  final String receiver;
  final String receiverNumber;
  final String rtvDate;

  const RtvOrderEntity({
    required this.orderId,
    required this.id,
    required this.destinationBranch,
    required this.receiver,
    required this.receiverNumber,
    required this.rtvDate,
  });

  @override
  List<Object?> get props => [
    orderId,
    id,
    destinationBranch,
    receiver,
    receiverNumber,
    rtvDate,
  ];
}
