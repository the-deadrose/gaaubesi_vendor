import 'package:equatable/equatable.dart';

class CodTransferList extends Equatable {
  final int id;
  final String amount;
  final String paymentId;
  final String receiver;
  final String notes;
  final String collectionMode;
  final DateTime createdOn;
  final String createdOnFormatted;
  final DateTime transferedOn;
  final String transferedOnFormatted;
  final String transactionMediumName;
  final int orderCount;
  final List<int> orderIds;
  final String amountBeforeCodt;

  const CodTransferList({
    required this.id,
    required this.amount,
    required this.paymentId,
    required this.receiver,
    required this.notes,
    required this.collectionMode,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.transferedOn,
    required this.transferedOnFormatted,
    required this.transactionMediumName,
    required this.orderCount,
    required this.orderIds,
    required this.amountBeforeCodt,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        paymentId,
        receiver,
        notes,
        collectionMode,
        createdOn,
        createdOnFormatted,
        transferedOn,
        transferedOnFormatted,
        transactionMediumName,
        orderCount,
        orderIds,
        amountBeforeCodt,
      ];
}
