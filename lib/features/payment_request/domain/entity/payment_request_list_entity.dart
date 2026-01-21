import 'package:equatable/equatable.dart';

class PaymentRequestListEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<PaymentRequestEntity> results;
  final List<PaymentMethodEntity> paymentMethods;
  final List<BankNameEntity> bankNames;

  const PaymentRequestListEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
    required this.paymentMethods,
    required this.bankNames,
  });

  @override
  List<Object?> get props =>
      [count, next, previous, results, paymentMethods, bankNames];
}

class PaymentRequestEntity extends Equatable {
  final int id;
  final String? paymentMethodId;
  final String? paymentMethodName;
  final String? paymentBankName;
  final String? paymentAccountName;
  final String? paymentAccountNumber;
  final String? paymentPhoneNumber;
  final String? paymentPersonName;
  final String? paymentPersonPhone;
  final String description;
  final String? reply;
  final String status;
  final String statusDisplay;
  final DateTime createdOn;
  final String createdOnFormatted;
  final DateTime? closedOn;
  final String closedOnFormatted;
  final String closedByName;

  const PaymentRequestEntity({
    required this.id,
    this.paymentMethodId,
    this.paymentMethodName,
    this.paymentBankName,
    this.paymentAccountName,
    this.paymentAccountNumber,
    this.paymentPhoneNumber,
    this.paymentPersonName,
    this.paymentPersonPhone,
    required this.description,
    this.reply,
    required this.status,
    required this.statusDisplay,
    required this.createdOn,
    required this.createdOnFormatted,
    this.closedOn,
    required this.closedOnFormatted,
    required this.closedByName,
  });

  @override
  List<Object?> get props => [id];
}

class PaymentMethodEntity extends Equatable {
  final String id;
  final String name;

  const PaymentMethodEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class BankNameEntity extends Equatable {
  final String name;

  const BankNameEntity({required this.name});

  @override
  List<Object?> get props => [name];
}
