import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/staff/data/model/staff_available_permission_model.dart';
import 'package:gaaubesi_vendor/features/staff/data/model/staff_list_model.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_available_permission_entity.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class StaffDatasource {
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

@LazySingleton(as: StaffDatasource)
class StaffDatasourceImpl implements StaffDatasource {
  final DioClient _dioClient;
  StaffDatasourceImpl(this._dioClient);

  @override
  Future<Either<Failure, StaffListEntity>> getStaffList() async {
    // try {
    final response = await _dioClient.get(ApiEndpoints.staffList);
    final staffList = StaffListModel.fromJson(response.data);
    return Right(staffList);
    // } catch (e) {
    //   return Left(ServerFailure('Failed to fetch staff list: $e'));
    // }
  }

  @override
  Future<Either<Failure, void>> changeUserPassword({
    required String userId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final endpoint =
          '${ApiEndpoints.vendorStaffInfoAPI}$userId/change-password/';
      final body = {
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };
      await _dioClient.patch(endpoint, data: body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to change password: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> editStaffProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String userName,
  }) async {
    try {
      final endpoint = '${ApiEndpoints.vendorStaffInfoAPI}$userId/change-info/';
      final body = {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'username': userName,
      };
      await _dioClient.patch(endpoint, data: body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to edit staff profile: $e'));
    }
  }

  @override
  Future<Either<Failure, StaffAvailablePermissionEntity>>
  getStaffAvailablePermissions({
    required String userId,
    required String permissionType,
  }) async {
    try {
      final endpoint =
          '${ApiEndpoints.vendorStaffInfoAPI}$userId/available-permissions/';
      final response = await _dioClient.get(
        endpoint,
        queryParameters: {'permission_type': permissionType},
      );
      final permissions = StaffAvailablePermissionModel.fromJson(response.data);
      return Right(permissions);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch staff permissions: $e'));
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
  }) async {
    try {
      final body = {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'username': userName,
        'password': password,
        'confirm_password': confirmPassword,
      };
      await _dioClient.post(ApiEndpoints.createStaff, data: body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to create staff: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> editStaffPermission({
    required String userId,
    required String permissionType,
    required List<int> permissionIds,
  }) async {
    try {
      final endpoint =
          '${ApiEndpoints.vendorStaffInfoAPI}$userId/add-permission/';
      final body = {
        'permission_type': permissionType,
        'permission_ids': permissionIds,
      };
      await _dioClient.patch(endpoint, data: body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to edit staff permissions: $e'));
    }
  }
}
