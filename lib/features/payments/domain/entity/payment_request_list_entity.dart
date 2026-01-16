import 'package:equatable/equatable.dart';

class PaymentRequestList extends Equatable {
  final List<PaymentMethodEntity> paymentMethods;
  final List<BankNameEntity> bankNames;
  final List<FrequentlyUsedMethodEntity> frequentlyUsedMethods;

  const PaymentRequestList({
    required this.paymentMethods,
    required this.bankNames,
    required this.frequentlyUsedMethods,
  });

  @override
  List<Object?> get props => [
        paymentMethods,
        bankNames,
        frequentlyUsedMethods,
      ];
}

class PaymentMethodEntity extends Equatable {
  final String id;
  final String name;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class BankNameEntity extends Equatable {
  final String name;

  const BankNameEntity({required this.name});

  @override
  List<Object?> get props => [name];
}

class FrequentlyUsedMethodEntity extends Equatable {
  final int id;
  final PaymentMethodEntity paymentMethod;
  final String? paymentBankName;
  final String? paymentAccountName;
  final String? paymentAccountNumber;
  final String? paymentPhoneNumber;
  final String? paymentPersonName;
  final String? paymentPersonPhone;
  final String renderPaymentDetails;

  const FrequentlyUsedMethodEntity({
    required this.id,
    required this.paymentMethod,
    this.paymentBankName,
    this.paymentAccountName,
    this.paymentAccountNumber,
    this.paymentPhoneNumber,
    this.paymentPersonName,
    this.paymentPersonPhone,
    required this.renderPaymentDetails,
  });

  @override
  List<Object?> get props => [
        id,
        paymentMethod,
        paymentBankName,
        paymentAccountName,
        paymentAccountNumber,
        paymentPhoneNumber,
        paymentPersonName,
        paymentPersonPhone,
        renderPaymentDetails,
      ];
}
