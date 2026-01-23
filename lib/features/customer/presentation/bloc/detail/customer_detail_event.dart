import 'package:equatable/equatable.dart';

abstract class CustomerDetailEvent extends Equatable {
  const CustomerDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomerDetail extends CustomerDetailEvent {
  final String customerId;

  const FetchCustomerDetail(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class ResetCustomerDetailState extends CustomerDetailEvent {
  const ResetCustomerDetailState();

  @override
  List<Object?> get props => [];
}