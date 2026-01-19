import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/usecase/fetch_daily_transaction_usecase.dart';
import 'package:injectable/injectable.dart';
import 'daily_transaction_event.dart';
import 'daily_transaction_state.dart';

@injectable
class DailyTransactionBloc
    extends Bloc<DailyTransactionEvent, DailyTransactionState> {
  final FetchDailyTransactionUsecase _usecase;

  DailyTransactionBloc(this._usecase) : super(DailyTransactionListInitial()) {
    on<FetchDailyTransactionEvent>(_onFetchDailyTransactions);
  }

  Future<void> _onFetchDailyTransactions(
    FetchDailyTransactionEvent event,
    Emitter<DailyTransactionState> emit,
  ) async {
    emit(DailyTransactionListLoading());

    final params = FetchDailyTransactionUsecaseParams(date: event.date);

    final result = await _usecase.call(params);

    result.fold(
      (failure) => emit(
        DailyTransactionListError(message: _mapFailureToMessage(failure)),
      ),
      (dailyTransactions) => emit(
        DailyTransactionListLoaded(dailyTransections: dailyTransactions),
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}
