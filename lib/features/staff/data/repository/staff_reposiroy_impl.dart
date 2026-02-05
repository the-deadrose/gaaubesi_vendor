import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/staff/data/datasource/staff_datasource.dart';
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
}
