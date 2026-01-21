import 'package:equatable/equatable.dart';

class FrequentlyUsedAndPaymentMethodList extends Equatable {
  final List<PaymentMethod> paymentMethods;
  final List<BankName> bankNames;
  final List<FrequentlyUsedMethod> frequentlyUsedMethods;

  const FrequentlyUsedAndPaymentMethodList({
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

class PaymentMethod extends Equatable {
  final String id;
  final String name;

  const PaymentMethod({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class BankName extends Equatable {
  final String name;

  const BankName({
    required this.name,
  });

  @override
  List<Object?> get props => [name];
}

class FrequentlyUsedMethod extends Equatable {
  final int id;
  final PaymentMethod paymentMethod;
  final String? paymentBankName;
  final String? paymentAccountName;
  final String? paymentAccountNumber;
  final String? paymentPhoneNumber;
  final String? paymentPersonName;
  final String? paymentPersonPhone;
  final String renderPaymentDetails;

  const FrequentlyUsedMethod({
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
