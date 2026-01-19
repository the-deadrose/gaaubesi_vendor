import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/usecase/cod_transfer_list_usecase.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_event.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CodTransferBloc extends Bloc<CodTransferEvent, CodTransferState> {
  final CodTransferListUsecase codTransferListUsecase;

  CodTransferBloc({required this.codTransferListUsecase})
    : super(const CodTransferListInitial()) {
    on<FetchCodTransferList>(_onFetchCodTransferList);
  }

  Future<void> _onFetchCodTransferList(
    FetchCodTransferList event,
    Emitter<CodTransferState> emit,
  ) async {
    final isPaginating =
        state is CodTransferListLoaded || state is CodTransferListPaginated;

    if (isPaginating) {
      emit(const CodTransferListPaginating());
    } else {
      emit(const CodTransferListLoading());
    }

    final result = await codTransferListUsecase(
      CodTransferListUsecaseParams(page: event.page),
    );

    result.fold(
      (failure) {
        if (isPaginating) {
          emit(CodTransferListPaginatingError(message: failure.message));
        } else {
          emit(CodTransferListError(message: failure.message));
        }
      },
      (codTransferList) {
        if (isPaginating) {
          emit(CodTransferListPaginated(codTransferList: codTransferList));
        } else {
          emit(CodTransferListLoaded(codTransferList: codTransferList));
        }
      },
    );
  }
}
