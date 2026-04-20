import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  final OrderDetailEntity order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Transient state emitted when an edit succeeds, before the refreshed data
/// arrives. UI layer should listen and show a confirmation (snackbar).
class OrderEditSuccess extends OrderDetailState {
  final OrderDetailEntity order;

  const OrderEditSuccess({required this.order});

  @override
  List<Object?> get props => [order, DateTime.now().microsecondsSinceEpoch];
}

/// Transient state emitted when an edit fails. Carries the last-known loaded
/// order so the UI can restore it after showing the error.
class OrderEditFailure extends OrderDetailState {
  final String message;
  final OrderDetailEntity? order;

  const OrderEditFailure({required this.message, this.order});

  @override
  List<Object?> get props => [message, order, DateTime.now().microsecondsSinceEpoch];
}
