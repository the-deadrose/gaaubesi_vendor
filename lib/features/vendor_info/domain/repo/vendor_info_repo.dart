import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';

abstract class VendorInfoRepo {
  Future<Either<Failure, VendorInfoEntity>> getVendorInfo();
}
