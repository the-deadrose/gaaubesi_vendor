import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/branch/data/datasource/branch_list_datasource.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/repository/branch_list_repository.dart';

@LazySingleton(as: BranchListRepository)
class BranchListRepoImp implements BranchListRepository {
  final BranchListRemoteDatasource remoteDatasource;

  BranchListRepoImp({required this.remoteDatasource});

  @override
  Future<Either<ServerFailure, List<OrderStatusEntity>>> getBranchList() async {
    try {
      final branchList = await remoteDatasource.fetchBranchList();
      return Right(branchList);
    } on DioException catch (e) {
    
      if (e.type == DioExceptionType.cancel) {
        debugPrint('[BranchListRepo] Session expired, returning silent failure');
        return Left(ServerFailure('Session expired'));
      }
      return Left(ServerFailure(e.message ?? 'Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[BranchListRepo] Unexpected error: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
