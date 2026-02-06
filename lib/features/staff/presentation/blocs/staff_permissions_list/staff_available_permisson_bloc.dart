import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/fetch_staff_available_permission_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/edit_staff_permission_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_permissions_list/staff_available_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_permissions_list/staff_available_permission_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class StaffAvailablePermissionBloc
    extends Bloc<StaffAvailablePermissionEvent, StaffAvailablePermissionState> {
  final FetchStaffAvailablePermissionUsecase
      fetchStaffAvailablePermissionUsecase;
  final EditStaffPermissionUsecase editStaffPermissionUsecase;

  StaffAvailablePermissionBloc({
    required this.fetchStaffAvailablePermissionUsecase,
    required this.editStaffPermissionUsecase,
  }) : super(StaffAvailablePermissionInitial()) {
    on<FetchStaffAvailablePermissions>(_onFetchPermissions);
    on<RefreshStaffAvailablePermissions>(_onRefreshPermissions);
    on<UpdateStaffPermissions>(_onUpdatePermissions);
  }

  Future<void> _onFetchPermissions(
    FetchStaffAvailablePermissions event,
    Emitter<StaffAvailablePermissionState> emit,
  ) async {
    emit(StaffAvailablePermissionLoading());

    final result = await fetchStaffAvailablePermissionUsecase(
      FetchStaffAvailablePermissionUsecaseParam(
        userId: event.userId,
        permissionType: event.permissionType,
      ),
    );

    result.fold(
      (failure) {
        emit(StaffAvailablePermissionError(message: failure.message));
      },
      (permissions) {
        if (permissions.permissions.isEmpty) {
          emit(StaffAvailablePermissionEmpty());
        } else {
          emit(StaffAvailablePermissionLoaded(
            permissions: permissions,
            permissionType: event.permissionType,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshPermissions(
    RefreshStaffAvailablePermissions event,
    Emitter<StaffAvailablePermissionState> emit,
  ) async {
    final result = await fetchStaffAvailablePermissionUsecase(
      FetchStaffAvailablePermissionUsecaseParam(
        userId: event.userId,
        permissionType: event.permissionType,
      ),
    );

    result.fold(
      (failure) {
        emit(StaffAvailablePermissionError(message: failure.message));
      },
      (permissions) {
        if (permissions.permissions.isEmpty) {
          emit(StaffAvailablePermissionEmpty());
        } else {
          emit(StaffAvailablePermissionLoaded(
            permissions: permissions,
            permissionType: event.permissionType,
          ));
        }
      },
    );
  }

  Future<void> _onUpdatePermissions(
    UpdateStaffPermissions event,
    Emitter<StaffAvailablePermissionState> emit,
  ) async {
    emit(StaffPermissionUpdating());

    final result = await editStaffPermissionUsecase(
      EditStaffPermissionParams(
        userId: event.userId,
        permissionType: event.permissionType,
        permissionIds: event.permissionIds,
      ),
    );

    result.fold(
      (failure) {
        emit(StaffPermissionUpdateError(message: failure.message));
      },
      (_) {
        emit(StaffPermissionUpdateSuccess(
          message: 'Permissions updated successfully',
        ));
        // Refresh permissions after update
        add(RefreshStaffAvailablePermissions(
          userId: event.userId,
          permissionType: event.permissionType,
        ));
      },
    );
  }
}
