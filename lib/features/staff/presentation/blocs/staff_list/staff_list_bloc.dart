import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/fetch_staff_list_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_list/staff_list_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_list/staff_list_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class StaffListBloc extends Bloc<StaffListEvent, StaffListState> {
  final FetchStaffListUsecase _fetchStaffListUsecase;

  StaffListBloc({required FetchStaffListUsecase fetchStaffListUsecase})
    : _fetchStaffListUsecase = fetchStaffListUsecase,
      super(StaffListInitial()) {
    on<FetchStaffListEvent>(_onFetchStaffList);
    on<RefreshStaffListEvent>(_onRefreshStaffList);
  }

  Future<void> _onFetchStaffList(
    FetchStaffListEvent event,
    Emitter<StaffListState> emit,
  ) async {
    emit(StaffListLoading());

    final result = await _fetchStaffListUsecase.call(NoParams());

    result.fold((failure) => emit(StaffListError(message: failure.message)), (
      staffList,
    ) {
      if (staffList.data.isEmpty) {
        emit(StaffListEmpty());
      } else {
        emit(StaffListLoaded(staffListEntity: staffList));
      }
    });
  }

  Future<void> _onRefreshStaffList(
    RefreshStaffListEvent event,
    Emitter<StaffListState> emit,
  ) async {
    emit(StaffListLoading());

    final result = await _fetchStaffListUsecase.call(NoParams());

    result.fold((failure) => emit(StaffListError(message: failure.message)), (
      staffList,
    ) {
      if (staffList.data.isEmpty) {
        emit(StaffListEmpty());
      } else {
        emit(StaffListLoaded(staffListEntity: staffList));
      }
    });
  }
}
