import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_available_permission_entity.dart';
import 'package:gaaubesi_vendor/features/staff/domain/repository/staff_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchStaffAvailablePermissionUsecase
    implements
        UseCase<
          StaffAvailablePermissionEntity,
          FetchStaffAvailablePermissionUsecaseParam
        > {
  final StaffRepository _staffRepository;

  FetchStaffAvailablePermissionUsecase(this._staffRepository);

  @override
  Future<Either<Failure, StaffAvailablePermissionEntity>> call(
    FetchStaffAvailablePermissionUsecaseParam params,
  ) {
    return _staffRepository.getStaffAvailablePermissions(
      userId: params.userId,
      permissionType: params.permissionType,
    );
  }
}

class FetchStaffAvailablePermissionUsecaseParam {
  final String userId;
  final String permissionType;

  FetchStaffAvailablePermissionUsecaseParam({
    required this.userId,
    required this.permissionType,
  });
}
