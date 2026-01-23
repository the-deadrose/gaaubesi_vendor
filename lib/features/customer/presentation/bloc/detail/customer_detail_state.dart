import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_detail_entity.dart';

abstract class CustomerDetailState extends Equatable {
  const CustomerDetailState();

  @override
  List<Object?> get props => [];
}

class CustomerDetailInitial extends CustomerDetailState {}

class CustomerDetailLoading extends CustomerDetailState {}

class CustomerDetailLoaded extends CustomerDetailState {
  final CustomerDetailEntity customerDetail;

  const CustomerDetailLoaded({required this.customerDetail});

  @override
  List<Object?> get props => [customerDetail];
}

class CustomerDetailError extends CustomerDetailState {
  final String message;

  const CustomerDetailError(this.message);

  @override
  List<Object?> get props => [message];
}