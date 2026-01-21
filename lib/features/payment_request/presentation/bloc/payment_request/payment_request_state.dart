import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/payment_request_list_entity.dart';

class PaymentRequestState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreatePayementRequestInitial extends PaymentRequestState {}

class CreatePaymentRequestLoading extends PaymentRequestState {}

class CreatePaymentRequestSuccess extends PaymentRequestState {
  final String message;

  CreatePaymentRequestSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreatePaymentRequestFailure extends PaymentRequestState {
  final String error;

  CreatePaymentRequestFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class FetchPaymentRequestsInitial extends PaymentRequestState {}

class FetchPaymentRequestsLoading extends PaymentRequestState {}

class PaymentRequestListEmpty extends PaymentRequestState {}

class FetchPaymentRequestsSuccess extends PaymentRequestState {
  final PaymentRequestListEntity paymentRequestList;

  FetchPaymentRequestsSuccess({required this.paymentRequestList});

  @override
  List<Object?> get props => [paymentRequestList];
}

class FetchPaymentRequestsFailure extends PaymentRequestState {
  final String error;

  FetchPaymentRequestsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
