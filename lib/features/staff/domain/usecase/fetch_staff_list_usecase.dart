import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_list_entity.dart';
import 'package:gaaubesi_vendor/features/staff/domain/repository/staff_repository.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class FetchStaffListUsecase implements UseCase<StaffListEntity , NoParams>{
  final StaffRepository _staffRepository;
  FetchStaffListUsecase(this._staffRepository);

  @override
  Future<Either<Failure, StaffListEntity>> call(NoParams params) {
    return _staffRepository.getStaffList();
  }
}