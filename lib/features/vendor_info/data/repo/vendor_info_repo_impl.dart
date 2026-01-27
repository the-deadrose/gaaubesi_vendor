import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/vendor_info/data/datasource/vendor_info_datasource.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/repo/vendor_info_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: VendorInfoRepo)
class VendorInfoRepoImpl implements VendorInfoRepo {
  final VendorInfoRemoteDatasource remoteDatasource;

  VendorInfoRepoImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, VendorInfoEntity>> getVendorInfo() async {
    try {
      final result = await remoteDatasource.getVendorInfo();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch vendor info: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateVendorInfo({
    required String address,
    required int? nearestPickupPoint,
    required double? latitude,
    required double? longitude,
    required String? profilePicture,
  }) async {
    try {
      final result = await remoteDatasource.updateVendorInfo(
        address: address,
        nearestPickupPoint: nearestPickupPoint,
        latitude: latitude,
        longitude: longitude,
        profilePicture: profilePicture,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to update vendor info: $e'));
    }
  }
}
