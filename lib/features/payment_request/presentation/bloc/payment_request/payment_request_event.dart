import 'package:equatable/equatable.dart';

abstract class PaymentRequestEvent extends Equatable {
  const PaymentRequestEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentRequestEvent extends PaymentRequestEvent {
  final String paymentMethod;
  final String description;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String phoneNumber;

  const CreatePaymentRequestEvent({
    required this.paymentMethod,
    required this.description,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [paymentMethod, description];
}

class FetchPaymentRequestsEvent extends PaymentRequestEvent {
  final String page;
  final String status;
  final String paymentMethod;
  final String bankName;

  const FetchPaymentRequestsEvent({
    required this.page,
    required this.status,
    required this.paymentMethod,
    required this.bankName,
  });

  @override
  List<Object?> get props => [page, status, paymentMethod, bankName];
}
