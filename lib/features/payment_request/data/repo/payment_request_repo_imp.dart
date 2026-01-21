import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/payment_request/data/datasource/payment_request_datasource.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/frequently_used_and_payment_method_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/repo/payment_request_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PaymentRequestRepo)
class PaymentRequestRepoImp implements PaymentRequestRepo {
  final PaymentRequestRemoteDatasource remoteDatasource;

  PaymentRequestRepoImp({required this.remoteDatasource});
  @override
  Future<Either<Failure, FrequentlyUsedAndPaymentMethodList>>
  getFrequentlyUsedMethodDetails() async {
    try {
      final response = await remoteDatasource
          .fetchFrequentlyUsedMethodDetails();
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createPaymentRequest({
    required String paymentMethod,
    required String description,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String phoneNumber,
  }) async {
    try {
      final response = await remoteDatasource.createPaymentRequest(
        paymentMethod: paymentMethod,
        discribtion: description,
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        phoneNumber: phoneNumber,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentRequestListEntity>> getPaymentRequests({
    required String page,
    required String status,
    required String paymentMethod,
    required String bankName,
  }) async {
    // try {
      final response = await remoteDatasource.fetchPaymentRequests(
        page: page,
        status: status,
        paymentMethod: paymentMethod,
        bankName: bankName,
      );
      return Right(response);
    // } catch (e) {
    //   return Left(ServerFailure(e.toString()));
    // }
  }
}
