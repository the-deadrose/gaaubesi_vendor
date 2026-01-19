import 'package:gaaubesi_vendor/features/cod_transfer/domain/entity/cod_transfer_entity.dart';

abstract class CodTransferRepo {
  Future<List<CodTransferList>> fetchCodTransfers({String page});
}
