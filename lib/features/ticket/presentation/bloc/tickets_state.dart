import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/ticket_entity.dart';

class TicketsState extends Equatable {
  const TicketsState();
  
  @override
  List<Object?> get props => [];
}

// Create Ticket States
class CreateTicketInitialState extends TicketsState {}

class CreateTicketLoadingState extends TicketsState {}

class CreateTicketSuccessState extends TicketsState {}

class CreateTicketFailureState extends TicketsState {
  final String errorMessage;

  const CreateTicketFailureState({required this.errorMessage});
  
  @override
  List<Object?> get props => [errorMessage];
}

// Ticket List States
class TicketsInitial extends TicketsState {}

class TicketsLoading extends TicketsState {}

class PendingTicketsLoaded extends TicketsState {
  final TicketResponseEntity response;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final bool isRefreshing;

  const PendingTicketsLoaded({
    required this.response,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [response, isLoadingMore, hasReachedMax, isRefreshing];
}

class ClosedTicketsLoaded extends TicketsState {
  final TicketResponseEntity response;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final bool isRefreshing;

  const ClosedTicketsLoaded({
    required this.response,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [response, isLoadingMore, hasReachedMax, isRefreshing];
}

class TicketsError extends TicketsState {
  final String message;
  final TicketResponseEntity? previousResponse;

  const TicketsError({
    required this.message,
    this.previousResponse,
  });

  @override
  List<Object?> get props => [message, previousResponse];
}

// Legacy states for backward compatibility
class FetchTicketsInitialState extends TicketsState {}
class FetchTicketsLoadingState extends TicketsState {}
class FetchTicketsSuccessState extends TicketsState {}
class FetchTicketsFailureState extends TicketsState {
  final String errorMessage;

  const FetchTicketsFailureState({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}