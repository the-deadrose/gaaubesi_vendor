import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_available_permission_entity.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_list_entity.dart';

abstract class StaffRepository {
  Future<Either<Failure, StaffListEntity>> getStaffList();
  Future<Either<Failure, void>> changeUserPassword({
    required String userId,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, void>> editStaffProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String userName,
  });

  Future<Either<Failure, StaffAvailablePermissionEntity>>
  getStaffAvailablePermissions({
    required String userId,
    required String permissionType,
  });

  Future<Either<Failure, void>> createStaff({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String userName,
    required String password,
    required String confirmPassword,
  });

  Future<Either<Failure, void>> editStaffPermission({
    required String userId,
    required String permissionType,
    required List<int> permissionIds,
  });
}
