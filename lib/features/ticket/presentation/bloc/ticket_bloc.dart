import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/ticket_entity.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/usecase/create_ticket_usecase.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/usecase/tickets_list_usecase.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_events.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/tickets_state.dart';

@injectable
class TicketBloc extends Bloc<TicketEvents, TicketsState> {
  final CreateTicketUseCase createTicketUseCase;
  final TicketsListUseCase ticketsListUseCase;

  TicketBloc({required this.createTicketUseCase , required this.ticketsListUseCase})
      : super(TicketsInitial()) {
    on<CreateTicketEvent>((event, emit) async {
      emit(CreateTicketLoadingState());
      final result = await createTicketUseCase(
        CreateTicketParams(
          subject: event.subject,
          description: event.description,
        ),
      );
      result.fold(
        (failure) => emit(CreateTicketFailureState(errorMessage: failure.toString())),
        (_) => emit(CreateTicketSuccessState()),
      );
    });

    on<FetchTicketsEvent>((event, emit) async {
      emit(FetchTicketsLoadingState());
      final result = await ticketsListUseCase(
        TicketsListParams(
          subject: event.status,
          description: event.page,
        ),
      );
      result.fold(
        (failure) => emit(FetchTicketsFailureState(errorMessage: failure.toString())),
        (response) => emit(FetchTicketsSuccessState()),
      );
    });

    on<FetchPendingTicketsEvent>((event, emit) async {
      final currentState = state;
      if (currentState is PendingTicketsLoaded && currentState.isRefreshing) {
        return;
      }
      
      emit(TicketsLoading());
      final result = await ticketsListUseCase(
        TicketsListParams(
          subject: 'pending',
          description: event.page,
        ),
      );
      
      result.fold(
        (failure) => emit(
          TicketsError(
            message: failure.toString(),
            previousResponse: currentState is PendingTicketsLoaded
                ? currentState.response
                : null,
          ),
        ),
        (response) => emit(
          PendingTicketsLoaded(
            response: response,
            hasReachedMax: response.next == null,
          ),
        ),
      );
    });

    on<FetchClosedTicketsEvent>((event, emit) async {
      final currentState = state;
      if (currentState is ClosedTicketsLoaded && currentState.isRefreshing) {
        return;
      }
      
      emit(TicketsLoading());
      final result = await ticketsListUseCase(
        TicketsListParams(
          subject: 'closed',
          description: event.page,
        ),
      );
      
      result.fold(
        (failure) => emit(
          TicketsError(
            message: failure.toString(),
            previousResponse: currentState is ClosedTicketsLoaded
                ? currentState.response
                : null,
          ),
        ),
        (response) => emit(
          ClosedTicketsLoaded(
            response: response,
            hasReachedMax: response.next == null,
          ),
        ),
      );
    });

    on<RefreshTicketsEvent>((event, emit) async {
      final currentState = state;
      
      if (event.isPending && currentState is PendingTicketsLoaded) {
        emit(
          PendingTicketsLoaded(
            response: currentState.response,
            isRefreshing: true,
          ),
        );
        
        final result = await ticketsListUseCase(
          const TicketsListParams(
            subject: 'pending',
            description: '1',
          ),
        );
        
        result.fold(
          (failure) => emit(
            TicketsError(
              message: failure.toString(),
              previousResponse: currentState.response,
            ),
          ),
          (response) => emit(
            PendingTicketsLoaded(
              response: response,
              hasReachedMax: response.next == null,
            ),
          ),
        );
      } else if (!event.isPending && currentState is ClosedTicketsLoaded) {
        emit(
          ClosedTicketsLoaded(
            response: currentState.response,
            isRefreshing: true,
          ),
        );
        
        final result = await ticketsListUseCase(
          const TicketsListParams(
            subject: 'closed',
            description: '1',
          ),
        );
        
        result.fold(
          (failure) => emit(
            TicketsError(
              message: failure.toString(),
              previousResponse: currentState.response,
            ),
          ),
          (response) => emit(
            ClosedTicketsLoaded(
              response: response,
              hasReachedMax: response.next == null,
            ),
          ),
        );
      }
    });

    on<FetchMoreTicketsEvent>((event, emit) async {
      final currentState = state;
      
      if (event.isPending && currentState is PendingTicketsLoaded && !currentState.hasReachedMax) {
        emit(
          PendingTicketsLoaded(
            response: currentState.response,
            isLoadingMore: true,
            hasReachedMax: currentState.hasReachedMax,
          ),
        );
        
        final nextPage = (currentState.response.results?.length ?? 0) ~/ 10 + 1;
        final result = await ticketsListUseCase(
          TicketsListParams(
            subject: 'pending',
            description: nextPage.toString(),
          ),
        );
        
        result.fold(
          (failure) => emit(
            TicketsError(
              message: failure.toString(),
              previousResponse: currentState.response,
            ),
          ),
          (newResponse) {
            final updatedResults = List<TicketEntity>.from(currentState.response.results ?? [])
              ..addAll(newResponse.results ?? []);
            
            emit(
              PendingTicketsLoaded(
                response: TicketResponseEntity(
                  results: updatedResults,
                  count: newResponse.count,
                  next: newResponse.next,
                  previous: newResponse.previous,
                ),
                hasReachedMax: newResponse.next == null,
              ),
            );
          },
        );
      } else if (!event.isPending && currentState is ClosedTicketsLoaded && !currentState.hasReachedMax) {
        emit(
          ClosedTicketsLoaded(
            response: currentState.response,
            isLoadingMore: true,
            hasReachedMax: currentState.hasReachedMax,
          ),
        );
        
        final nextPage = (currentState.response.results?.length ?? 0) ~/ 10 + 1;
        final result = await ticketsListUseCase(
          TicketsListParams(
            subject: 'closed',
            description: nextPage.toString(),
          ),
        );
        
        result.fold(
          (failure) => emit(
            TicketsError(
              message: failure.toString(),
              previousResponse: currentState.response,
            ),
          ),
          (newResponse) {
            final updatedResults = List<TicketEntity>.from(currentState.response.results ?? [])
              ..addAll(newResponse.results ?? []);
            
            emit(
              ClosedTicketsLoaded(
                response: TicketResponseEntity(
                  results: updatedResults,
                  count: newResponse.count,
                  next: newResponse.next,
                  previous: newResponse.previous,
                ),
                hasReachedMax: newResponse.next == null,
              ),
            );
          },
        );
      }
    });
  }
}
