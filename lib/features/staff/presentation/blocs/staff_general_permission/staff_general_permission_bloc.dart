import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/fetch_staff_available_permission_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/edit_staff_permission_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_general_permission/staff_general_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_general_permission/staff_general_permission_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class StaffGeneralPermissionBloc
    extends Bloc<StaffGeneralPermissionEvent, StaffGeneralPermissionState> {
  final FetchStaffAvailablePermissionUsecase
      fetchStaffAvailablePermissionUsecase;
  final EditStaffPermissionUsecase editStaffPermissionUsecase;

  StaffGeneralPermissionBloc({
    required this.fetchStaffAvailablePermissionUsecase,
    required this.editStaffPermissionUsecase,
  }) : super(StaffGeneralPermissionInitial()) {
    on<FetchGeneralPermissions>(_onFetchPermissions);
    on<RefreshGeneralPermissions>(_onRefreshPermissions);
    on<UpdateGeneralPermissions>(_onUpdatePermissions);
  }

  Future<void> _onFetchPermissions(
    FetchGeneralPermissions event,
    Emitter<StaffGeneralPermissionState> emit,
  ) async {
    emit(StaffGeneralPermissionLoading());

    final result = await fetchStaffAvailablePermissionUsecase(
      FetchStaffAvailablePermissionUsecaseParam(
        userId: event.userId,
        permissionType: 'general',
      ),
    );

    result.fold(
      (failure) {
        emit(StaffGeneralPermissionError(message: failure.message));
      },
      (permissions) {
        if (permissions.permissions.isEmpty) {
          emit(StaffGeneralPermissionEmpty());
        } else {
          emit(StaffGeneralPermissionLoaded(permissions: permissions));
        }
      },
    );
  }

  Future<void> _onRefreshPermissions(
    RefreshGeneralPermissions event,
    Emitter<StaffGeneralPermissionState> emit,
  ) async {
    final result = await fetchStaffAvailablePermissionUsecase(
      FetchStaffAvailablePermissionUsecaseParam(
        userId: event.userId,
        permissionType: 'general',
      ),
    );

    result.fold(
      (failure) {
        emit(StaffGeneralPermissionError(message: failure.message));
      },
      (permissions) {
        if (permissions.permissions.isEmpty) {
          emit(StaffGeneralPermissionEmpty());
        } else {
          emit(StaffGeneralPermissionLoaded(permissions: permissions));
        }
      },
    );
  }

  Future<void> _onUpdatePermissions(
    UpdateGeneralPermissions event,
    Emitter<StaffGeneralPermissionState> emit,
  ) async {
    emit(StaffGeneralPermissionUpdating());

    final result = await editStaffPermissionUsecase(
      EditStaffPermissionParams(
        userId: event.userId,
        permissionType: 'general',
        permissionIds: event.permissionIds,
      ),
    );

    result.fold(
      (failure) {
        emit(StaffGeneralPermissionUpdateError(message: failure.message));
      },
      (_) {
        emit(StaffGeneralPermissionUpdateSuccess(
          message: 'Permissions updated successfully',
        ));
        // Refresh permissions after update
        add(RefreshGeneralPermissions(userId: event.userId));
      },
    );
  }
}
