import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/usecase/create_ticket_usecase.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/usecase/tickets_list_usecase.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_events.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/tickets_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketsListUseCase ticketsListUseCase;
  final CreateTicketUseCase createTicketUseCase;
  List<PendingTicketEntity> _allTickets = [];
  int _currentPage = 1;
  bool _hasReachedMax = false;

  TicketBloc({
    required this.ticketsListUseCase,
    required this.createTicketUseCase,
  }) : super(TicketInitial()) {
    on<FetchTicketsEvent>(_onFetchTickets);
    on<RefreshTicketsEvent>(_onRefreshTickets);
    on<CreateTicketEvent>(_onCreateTicket);
     on<CreateTicketReset>(_onCreateTicketReset);
  }

  FutureOr<void> _onFetchTickets(
    FetchTicketsEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      if (event.page == '1') {
        emit(TicketLoading());
        _allTickets.clear();
        _hasReachedMax = false;
      }

      final result = await ticketsListUseCase(
        TicketsListParams(page: event.page, subject: event.subject , status: event.status),
      );

      result.fold(
        (failure) {
          emit(TicketError(message: _mapFailureToMessage(failure)));
        },
        (newTickets) {
          if (newTickets.results.isEmpty) {
            if (event.page == '1') {
              emit(TicketEmpty());
            } else {
              _hasReachedMax = true;
              emit(
                TicketLoaded(
                  tickets: PendingTicketListEntity(
                    count: newTickets.count,
                    next: newTickets.next,
                    previous: newTickets.previous,
                    results: _allTickets,
                  ),
                  hasReachedMax: true,
                ),
              );
            }
          } else {
            _allTickets.addAll(newTickets.results);

            _currentPage = int.tryParse(event.page) ?? _currentPage;
            _hasReachedMax = newTickets.next == null;

            emit(
              TicketLoaded(
                tickets: PendingTicketListEntity(
                  count: newTickets.count,
                  next: newTickets.next,
                  previous: newTickets.previous,
                  results: _allTickets,
                ),
                hasReachedMax: _hasReachedMax,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (event.page == '1') {
        emit(TicketError(message: 'Failed to fetch tickets: $e'));
      } else {
        if (state is TicketLoaded) {
          emit((state as TicketLoaded).copyWith(hasReachedMax: false));
        }
      }
    }
  }

  FutureOr<void> _onRefreshTickets(
    RefreshTicketsEvent event,
    Emitter<TicketState> emit,
  ) async {
    try {
      emit(TicketLoading());

      final result = await ticketsListUseCase(
        TicketsListParams(page: '1', subject: event.subject , status: event.status),
      );

      result.fold(
        (failure) {
          emit(TicketError(message: _mapFailureToMessage(failure)));
        },
        (tickets) {
          _allTickets = tickets.results;
          _currentPage = 1;
          _hasReachedMax = tickets.next == null;

          if (tickets.results.isEmpty) {
            emit(TicketEmpty());
          } else {
            emit(TicketLoaded(tickets: tickets, hasReachedMax: _hasReachedMax));
          }
        },
      );
    } catch (e) {
      emit(TicketError(message: 'Failed to refresh tickets: $e'));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error. Please try again.';
    } else if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    } else if (failure is CacheFailure) {
      return 'Failed to load data from cache.';
    }
    return 'An unexpected error occurred.';
  }

  FutureOr<void> _onCreateTicket(
    CreateTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(CreateTicketLoading());

    final result = await createTicketUseCase(
      CreateTicketParams(description: event.description, subject: event.subject),
    );

    result.fold(
      (failure) {
        emit(CreateTicketFailure(error: _mapFailureToMessage(failure)));
      },
      (_) {
        emit(CreateTicketSuccess(message: 'Ticket created successfully'));
      },
    );
  }
  FutureOr<void> _onCreateTicketReset(
    CreateTicketReset event,
    Emitter<TicketState> emit,
  ) {
    if (state is CreateTicketLoading || 
        state is CreateTicketSuccess || 
        state is CreateTicketFailure) {
      emit(TicketInitial());
    }
  }
}