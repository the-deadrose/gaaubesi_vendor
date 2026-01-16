import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/payments/data/datasource/payement_request_datasource.dart';
import 'package:gaaubesi_vendor/features/payments/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payments/domain/repo/payment_request_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PaymentRequestRepo)

class PayemntRequestRepoImp implements PaymentRequestRepo {
  final PayementRequestRemoteDatasource remoteDataSource;

  PayemntRequestRepoImp({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaymentRequestList>> getPaymentRequestList() async {
    try {
      final result = await remoteDataSource.getPaymentRequestList();
      return Right(result);
    } on ServerException {
      return Left(ServerFailure('Failed to fetch payment request list'));
    }
  }

}