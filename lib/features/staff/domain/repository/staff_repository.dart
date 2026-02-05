import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
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
}
