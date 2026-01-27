import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/repo/vendor_info_repo.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class VendorUpdateUsecase extends UseCase<void, VendorUpdateParams> {
  final VendorInfoRepo vendorInfoRepo;

  VendorUpdateUsecase(this.vendorInfoRepo);

  @override
  Future<Either<Failure, void>> call(VendorUpdateParams params) async {
    return await vendorInfoRepo.updateVendorInfo(
      address: params.address,
      nearestPickupPoint: params.nearestPickupPoint,
      latitude: params.latitude,
      longitude: params.longitude,
      profilePicture: params.profilePicture,
    );
  }
}

class VendorUpdateParams {
  final String address;
  final int? nearestPickupPoint;
  final double? latitude;
  final double? longitude;
  final String? profilePicture;

  VendorUpdateParams({
    required this.address,
    this.nearestPickupPoint,
    this.latitude,
    this.longitude,
    this.profilePicture,
  });
}
