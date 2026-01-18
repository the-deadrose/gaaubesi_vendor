// features/ticket/presentation/bloc/ticket_state.dart
import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketLoaded extends TicketState {
  final PendingTicketListEntity tickets;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const TicketLoaded({
    required this.tickets,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  TicketLoaded copyWith({
    PendingTicketListEntity? tickets,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return TicketLoaded(
      tickets: tickets ?? this.tickets,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [tickets, hasReachedMax, isLoadingMore];
}

class TicketError extends TicketState {
  final String message;

  const TicketError({required this.message});

  @override
  List<Object> get props => [message];
}

class TicketEmpty extends TicketState {}

// Extend CreateTicketState from TicketState instead of Equatable
class CreateTicketLoading extends TicketState {}

class CreateTicketSuccess extends TicketState {
  final String message;

  const CreateTicketSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class CreateTicketFailure extends TicketState {
  final String error;

  const CreateTicketFailure({required this.error});

  @override
  List<Object> get props => [error];
}