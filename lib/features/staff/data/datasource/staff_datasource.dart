import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/staff/data/model/staff_list_model.dart';
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
}
