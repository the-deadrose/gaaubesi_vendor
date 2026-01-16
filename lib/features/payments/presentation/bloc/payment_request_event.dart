import 'package:equatable/equatable.dart';

abstract class PaymentRequestEvent extends Equatable {
  const PaymentRequestEvent();

  @override
  List<Object> get props => [];
}

class LoadPaymentRequestList extends PaymentRequestEvent {
  const LoadPaymentRequestList();
}

class RefreshPaymentRequestList extends PaymentRequestEvent {
  const RefreshPaymentRequestList();
}
