import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/fetch_staff_available_permission_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/edit_staff_permission_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_order_permission/staff_order_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_order_permission/staff_order_permission_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class StaffOrderPermissionBloc
    extends Bloc<StaffOrderPermissionEvent, StaffOrderPermissionState> {
  final FetchStaffAvailablePermissionUsecase
      fetchStaffAvailablePermissionUsecase;
  final EditStaffPermissionUsecase editStaffPermissionUsecase;

  StaffOrderPermissionBloc({
    required this.fetchStaffAvailablePermissionUsecase,
    required this.editStaffPermissionUsecase,
  }) : super(StaffOrderPermissionInitial()) {
    on<FetchOrderPermissions>(_onFetchPermissions);
    on<RefreshOrderPermissions>(_onRefreshPermissions);
    on<UpdateOrderPermissions>(_onUpdatePermissions);
  }

  Future<void> _onFetchPermissions(
    FetchOrderPermissions event,
    Emitter<StaffOrderPermissionState> emit,
  ) async {
    emit(StaffOrderPermissionLoading());

    final result = await fetchStaffAvailablePermissionUsecase(
      FetchStaffAvailablePermissionUsecaseParam(
        userId: event.userId,
        permissionType: 'order',
      ),
    );

    result.fold(
      (failure) {
        emit(StaffOrderPermissionError(message: failure.message));
      },
      (permissions) {
        if (permissions.permissions.isEmpty) {
          emit(StaffOrderPermissionEmpty());
        } else {
          emit(StaffOrderPermissionLoaded(permissions: permissions));
        }
      },
    );
  }

  Future<void> _onRefreshPermissions(
    RefreshOrderPermissions event,
    Emitter<StaffOrderPermissionState> emit,
  ) async {
    final result = await fetchStaffAvailablePermissionUsecase(
      FetchStaffAvailablePermissionUsecaseParam(
        userId: event.userId,
        permissionType: 'order',
      ),
    );

    result.fold(
      (failure) {
        emit(StaffOrderPermissionError(message: failure.message));
      },
      (permissions) {
        if (permissions.permissions.isEmpty) {
          emit(StaffOrderPermissionEmpty());
        } else {
          emit(StaffOrderPermissionLoaded(permissions: permissions));
        }
      },
    );
  }

  Future<void> _onUpdatePermissions(
    UpdateOrderPermissions event,
    Emitter<StaffOrderPermissionState> emit,
  ) async {
    emit(StaffOrderPermissionUpdating());

    final result = await editStaffPermissionUsecase(
      EditStaffPermissionParams(
        userId: event.userId,
        permissionType: 'order',
        permissionIds: event.permissionIds,
      ),
    );

    result.fold(
      (failure) {
        emit(StaffOrderPermissionUpdateError(message: failure.message));
      },
      (_) {
        emit(StaffOrderPermissionUpdateSuccess(
          message: 'Permissions updated successfully',
        ));
        // Refresh permissions after update
        add(RefreshOrderPermissions(userId: event.userId));
      },
    );
  }
}
