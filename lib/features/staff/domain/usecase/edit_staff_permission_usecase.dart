import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/repository/staff_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class EditStaffPermissionUsecase
    implements UseCase<void, EditStaffPermissionParams> {
  final StaffRepository _staffRepository;

  EditStaffPermissionUsecase(this._staffRepository);

  @override
  Future<Either<Failure, void>> call(EditStaffPermissionParams params) {
    return _staffRepository.editStaffPermission(
      userId: params.userId,
      permissionType: params.permissionType,
      permissionIds: params.permissionIds,
    );
  }
}

class EditStaffPermissionParams {
  final String userId;
  final String permissionType;
  final List<int> permissionIds;

  EditStaffPermissionParams({
    required this.userId,
    required this.permissionType,
    required this.permissionIds,
  });
}
