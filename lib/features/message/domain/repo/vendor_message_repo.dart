import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/message/domain/entity/vendor_message_list_entity.dart';

abstract class VendorMessageRepository {
  Future<Either<Failure, VendorMessageListEntity>> sendVendorMessage(
    String page,
  );
}
