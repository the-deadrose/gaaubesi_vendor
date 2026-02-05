import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/repository/staff_repository.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class ChangePasswordStaffUsecase
    implements UseCase<void, ChangePasswordStaffUsecaseParams> {
  final StaffRepository _staffRepository;

  ChangePasswordStaffUsecase(this._staffRepository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordStaffUsecaseParams params) {
    return _staffRepository.changeUserPassword(
      userId: params.userId,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}

class ChangePasswordStaffUsecaseParams {
  final String userId;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordStaffUsecaseParams({
    required this.userId,
    required this.newPassword,
    required this.confirmPassword,
  });
}
