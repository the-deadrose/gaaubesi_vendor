import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/repo/vendor_info_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VendorInfoUsecase extends UseCase<VendorInfoEntity, NoParams> {
  final VendorInfoRepo vendorInfoRepo;

  VendorInfoUsecase(this.vendorInfoRepo);

  @override
  Future<Either<Failure, VendorInfoEntity>> call(NoParams params) async {
    return await vendorInfoRepo.getVendorInfo();
  }
}
