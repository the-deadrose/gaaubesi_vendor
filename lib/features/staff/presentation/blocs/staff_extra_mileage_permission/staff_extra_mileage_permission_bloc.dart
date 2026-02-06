import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/fetch_staff_available_permission_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/edit_staff_permission_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_extra_mileage_permission/staff_extra_mileage_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_extra_mileage_permission/staff_extra_mileage_permission_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class StaffExtraMileagePermissionBloc
    extends Bloc<StaffExtraMileagePermissionEvent,
        StaffExtraMileagePermissionState> {
  final FetchStaffAvailablePermissionUsecase
      fetchStaffAvailablePermissionUsecase;
  final EditStaffPermissionUsecase editStaffPermissionUsecase;

  StaffExtraMileagePermissionBloc({
    required this.fetchStaffAvailablePermissionUsecase,
    required this.editStaffPermissionUsecase,
  }) : super(StaffExtraMileagePermissionInitial()) {
    on<FetchExtraMileagePermissions>(_onFetchPermissions);
    on<RefreshExtraMileagePermissions>(_onRefreshPermissions);
    on<UpdateExtraMileagePermissions>(_onUpdatePermissions);
  }

  Future<void> _onFetchPermissions(
    FetchExtraMileagePermissions event,
    Emitter<StaffExtraMileagePermissionState> emit,
  ) async {
    emit(StaffExtraMileagePermissionLoading());

    final result = await fetchStaffAvailablePermissionUsecase(
      FetchStaffAvailablePermissionUsecaseParam(
        userId: event.userId,
        permissionType: 'extra_mileage',
      ),
    );

    result.fold(
      (failure) {
        emit(StaffExtraMileagePermissionError(message: failure.message));
      },
      (permissions) {
        if (permissions.permissions.isEmpty) {
          emit(StaffExtraMileagePermissionEmpty());
        } else {
          emit(StaffExtraMileagePermissionLoaded(permissions: permissions));
        }
      },
    );
  }

  Future<void> _onRefreshPermissions(
    RefreshExtraMileagePermissions event,
    Emitter<StaffExtraMileagePermissionState> emit,
  ) async {
    final result = await fetchStaffAvailablePermissionUsecase(
      FetchStaffAvailablePermissionUsecaseParam(
        userId: event.userId,
        permissionType: 'extra_mileage',
      ),
    );

    result.fold(
      (failure) {
        emit(StaffExtraMileagePermissionError(message: failure.message));
      },
      (permissions) {
        if (permissions.permissions.isEmpty) {
          emit(StaffExtraMileagePermissionEmpty());
        } else {
          emit(StaffExtraMileagePermissionLoaded(permissions: permissions));
        }
      },
    );
  }

  Future<void> _onUpdatePermissions(
    UpdateExtraMileagePermissions event,
    Emitter<StaffExtraMileagePermissionState> emit,
  ) async {
    emit(StaffExtraMileagePermissionUpdating());

    final result = await editStaffPermissionUsecase(
      EditStaffPermissionParams(
        userId: event.userId,
        permissionType: 'extra_mileage',
        permissionIds: event.permissionIds,
      ),
    );

    result.fold(
      (failure) {
        emit(StaffExtraMileagePermissionUpdateError(message: failure.message));
      },
      (_) {
        emit(StaffExtraMileagePermissionUpdateSuccess(
          message: 'Permissions updated successfully',
        ));
        // Refresh permissions after update
        add(RefreshExtraMileagePermissions(userId: event.userId));
      },
    );
  }
}
