import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/payments/domain/entity/payment_request_list_entity.dart';

abstract class PaymentRequestState extends Equatable {
  const PaymentRequestState();

  @override
  List<Object> get props => [];
}

class PaymentRequestListInitial extends PaymentRequestState {}

class PaymentRequestListLoading extends PaymentRequestState {}

class PaymentRequestListLoaded extends PaymentRequestState {
  final PaymentRequestList paymentRequestList;

  const PaymentRequestListLoaded(this.paymentRequestList);

  @override
  List<Object> get props => [paymentRequestList];
}

class PaymentRequestListError extends PaymentRequestState {
  final Failure failure;

  const PaymentRequestListError(this.failure);

  @override
  List<Object> get props => [failure];
}

class PaymentRequestListEmpty extends PaymentRequestState {}