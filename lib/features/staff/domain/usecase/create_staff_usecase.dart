import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/repository/staff_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateStaffUsecase implements UseCase<void, CreateStaffUsecaseParams> {
  final StaffRepository _staffRepository;
  CreateStaffUsecase(this._staffRepository);

  @override
  Future<Either<Failure, void>> call(CreateStaffUsecaseParams params) {
    return _staffRepository.createStaff(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      userName: params.userName,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}

class CreateStaffUsecaseParams {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userName;
  final String password;
  final String confirmPassword;

  CreateStaffUsecaseParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userName,
    required this.password,
    required this.confirmPassword,
  });
}
