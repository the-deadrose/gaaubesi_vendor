import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/repository/staff_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class EditStaffInfoUsecase
    implements UseCase<void, EditStaffInfoUsecaseParams> {
  final StaffRepository _staffRepository;

  EditStaffInfoUsecase(this._staffRepository);

  @override
  Future<Either<Failure, void>> call(EditStaffInfoUsecaseParams params) {
    return _staffRepository.editStaffProfile(
      userId: params.userId,
      fullName: params.fullName,
      email: params.email,
      phone: params.phone,
      userName: params.userName,
    );
  }
}

class EditStaffInfoUsecaseParams {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String userName;

  EditStaffInfoUsecaseParams({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.userName,
  });
}
