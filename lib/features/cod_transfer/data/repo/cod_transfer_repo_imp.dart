import 'package:gaaubesi_vendor/features/cod_transfer/data/datasource/cod_transfer_datasource.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/entity/cod_transfer_entity.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/repo/cod_transfer_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CodTransferRepo)
class CodTransferRepoImp implements CodTransferRepo {
  final CodTransferRemoteDataource remoteDataSource;

  CodTransferRepoImp({required this.remoteDataSource});

  @override
  Future<List<CodTransferList>> fetchCodTransfers({String page = ''}) async {
    try {
      final result = await remoteDataSource.fetchCodTransferList(
        page: int.parse(page),
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
