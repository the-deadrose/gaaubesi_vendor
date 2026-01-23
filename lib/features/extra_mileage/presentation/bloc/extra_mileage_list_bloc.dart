import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/usecase/extra_mileage_usecase.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_milage_list_event.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_mileage_list_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ExtraMileageBloc extends Bloc<ExtraMileageEvent, ExtraMileageListState> {
  final ExtraMileageUsecase _extraMileageUsecase;
  String? _nextPageUrl;
  String _currentStatus = 'pending';
  String _currentStartDate = '';
  String _currentEndDate = '';
  List<ExtraMileageResponseEntity> _allResults = [];

  ExtraMileageBloc(this._extraMileageUsecase)
    : super(ExtraMileageListInitialState()) {
    on<FetchExtraMileageListEvent>(_onFetchExtraMileageList);
    on<LoadMoreExtraMileageEvent>(_onLoadMoreExtraMileage);
    on<RefreshExtraMileageListEvent>(_onRefreshExtraMileageList);
  }

  Future<void> _onFetchExtraMileageList(
    FetchExtraMileageListEvent event,
    Emitter<ExtraMileageListState> emit,
  ) async {
    emit(ExtraMileageListLoadingState());

    _currentStatus = event.status;
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;
    _allResults = [];

    final result = await _extraMileageUsecase.call(
      ExtraMileageParams(
        page: '1',
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(
        ExtraMileageListErrorState(message: _mapFailureToMessage(failure)),
      ),
      (response) {
        if (response.results.isEmpty) {
          emit(ExtraMileageListEmptyState());
        } else {
          _allResults = response.results;
          _nextPageUrl = response.next;
          emit(
            ExtraMileageListLoadedState(
              extraMileageList: ExtraMileageResponseListEntity(
                count: response.count,
                next: response.next,
                previous: response.previous,
                results: _allResults,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadMoreExtraMileage(
    LoadMoreExtraMileageEvent event,
    Emitter<ExtraMileageListState> emit,
  ) async {
    if (_nextPageUrl == null) return;

    emit(ExtraMileageListPaginatingState());

    final page = _extractPageNumber(_nextPageUrl!);
    if (page == null) {
      emit(
        ExtraMileageListLoadedState(
          extraMileageList: ExtraMileageResponseListEntity(
            count: _allResults.length,
            next: null,
            previous: null,
            results: _allResults,
          ),
        ),
      );
      return;
    }

    final result = await _extraMileageUsecase.call(
      ExtraMileageParams(
        page: page,
        status: _currentStatus,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      ),
    );

    result.fold(
      (failure) => emit(
        ExtraMileageListErrorState(message: _mapFailureToMessage(failure)),
      ),
      (response) {
        _allResults.addAll(response.results);
        _nextPageUrl = response.next;

        if (state is ExtraMileageListPaginatingState) {
          emit(
            ExtraMileageListPaginatedState(
              extraMileageList: ExtraMileageResponseListEntity(
                count: response.count,
                next: response.next,
                previous: response.previous,
                results: _allResults,
              ),
            ),
          );
        } else {
          emit(
            ExtraMileageListLoadedState(
              extraMileageList: ExtraMileageResponseListEntity(
                count: response.count,
                next: response.next,
                previous: response.previous,
                results: _allResults,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _onRefreshExtraMileageList(
    RefreshExtraMileageListEvent event,
    Emitter<ExtraMileageListState> emit,
  ) async {
    _currentStatus = event.status;
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;
    _allResults = [];

    final result = await _extraMileageUsecase.call(
      ExtraMileageParams(
        page: '1',
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(
        ExtraMileageListErrorState(message: _mapFailureToMessage(failure)),
      ),
      (response) {
        _allResults = response.results;
        _nextPageUrl = response.next;
        emit(
          ExtraMileageListLoadedState(
            extraMileageList: ExtraMileageResponseListEntity(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: _allResults,
            ),
          ),
        );
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred';
      case NetworkFailure _:
        return 'Please check your internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }

  String? _extractPageNumber(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['page'];
    } catch (e) {
      return null;
    }
  }

  bool get hasNextPage => _nextPageUrl != null;
}
