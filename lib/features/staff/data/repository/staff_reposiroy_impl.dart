import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/staff/data/datasource/staff_datasource.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_available_permission_entity.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_list_entity.dart';
import 'package:gaaubesi_vendor/features/staff/domain/repository/staff_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: StaffRepository)
class StaffReposiroyImpl implements StaffRepository {
  final StaffDatasource _staffDatasource;
  StaffReposiroyImpl(this._staffDatasource);
  @override
  Future<Either<Failure, StaffListEntity>> getStaffList() {
    try {
      final result = _staffDatasource.getStaffList();
      return result;
    } catch (e) {
      return Future.value(Left(ServerFailure('Failed to get staff list: $e')));
    }
  }

  @override
  Future<Either<Failure, void>> changeUserPassword({
    required String userId,
    required String newPassword,
    required String confirmPassword,
  }) {
    try {
      final result = _staffDatasource.changeUserPassword(
        userId: userId,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return result;
    } catch (e) {
      return Future.value(Left(ServerFailure('Failed to change password: $e')));
    }
  }

  @override
  Future<Either<Failure, void>> editStaffProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String userName,
  }) {
    try {
      final result = _staffDatasource.editStaffProfile(
        userId: userId,
        fullName: fullName,
        email: email,
        phone: phone,
        userName: userName,
      );
      return result;
    } catch (e) {
      return Future.value(
        Left(ServerFailure('Failed to edit staff profile: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, StaffAvailablePermissionEntity>>
  getStaffAvailablePermissions({required String userId , required String permissionType}) {
    try {
      final result = _staffDatasource.getStaffAvailablePermissions(
        userId: userId,
        permissionType: permissionType,
      );
      return result;
    } catch (e) {
      return Future.value(
        Left(ServerFailure('Failed to get staff permissions: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> createStaff({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String userName,
    required String password,
    required String confirmPassword,
  }) {
    try {
      final result = _staffDatasource.createStaff(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        userName: userName,
        password: password,
        confirmPassword: confirmPassword,
      );
      return result;
    } catch (e) {
      return Future.value(Left(ServerFailure('Failed to create staff: $e')));
    }
  }

  @override
  Future<Either<Failure, void>> editStaffPermission({
    required String userId,
    required String permissionType,
    required List<int> permissionIds,
  }) {
    try {
      final result = _staffDatasource.editStaffPermission(
        userId: userId,
        permissionType: permissionType,
        permissionIds: permissionIds,
      );
      return result;
    } catch (e) {
      return Future.value(
        Left(ServerFailure('Failed to edit staff permission: $e')),
      );
    }
  }
}
