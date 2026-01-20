import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/today_redirect_order_entity.dart';

class RedirectOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RedirectOrdersInitial extends RedirectOrderState {}
class RedirectOrdersLoading extends RedirectOrderState {}
class RedirectOrdersLoaded extends RedirectOrderState {
  final RedirectedOrders redirectedOrders;
  RedirectOrdersLoaded({required this.redirectedOrders});

  @override
  List<Object?> get props => [redirectedOrders];
}

class RedirectOrdersError extends RedirectOrderState {
  final String message;
  RedirectOrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RedirectOrdersEmpty extends RedirectOrderState {}

class RedirectOrdersPaginating extends RedirectOrderState {}

class RedirectOrdersPaginatingError extends RedirectOrderState {
  final String message;
  RedirectOrdersPaginatingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RedirectOrdersPaginated extends RedirectOrderState {
  final RedirectedOrders redirectedOrders;
  RedirectOrdersPaginated({required this.redirectedOrders});

  @override
  List<Object?> get props => [redirectedOrders];
}


class TodaysRedirectedOrderInitial extends RedirectOrderState {}

class TodaysRedirectedOrderLoading extends RedirectOrderState {}

class TodaysRedirectedOrderLoaded extends RedirectOrderState {
  final TodayRedirectOrderList redirectedOrders;
  TodaysRedirectedOrderLoaded({required this.redirectedOrders});

  @override
  List<Object?> get props => [redirectedOrders];
}

class TodaysRedirectedOrderError extends RedirectOrderState {
  final String message;
  TodaysRedirectedOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TodaysRedirectedOrderEmpty extends RedirectOrderState {}


class TodaysRedirectedOrderPaginating extends RedirectOrderState {}

class TodaysRedirectedOrderPaginatingError extends RedirectOrderState {
  final String message;
  TodaysRedirectedOrderPaginatingError({required this.message});

  @override
  List<Object?> get props => [message];
}


class  TodaysRedirectedOrderPaginated extends RedirectOrderState {
  final TodayRedirectOrderList redirectedOrders;
  TodaysRedirectedOrderPaginated({required this.redirectedOrders});

  @override
  List<Object?> get props => [redirectedOrders];
}