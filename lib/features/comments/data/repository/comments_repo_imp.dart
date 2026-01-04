import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/comments/data/datasource/comments_datasource.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/domain/repository/comments_repository.dart';

@LazySingleton(as: CommentsRepository)
class CommentsRepoImp implements CommentsRepository {
  final CommentsRemoteDatasource remoteDatasource;

  CommentsRepoImp({required this.remoteDatasource});

  @override
  Future<Either<ServerFailure, CommentsResponseEntity>> todaysComments(
    String page,
  ) async {
    try {
      final todaysComments = await remoteDatasource.fetchTodaysComments(page);
      return Right(todaysComments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<ServerFailure, CommentsResponseEntity>> allComments(
    String page,
  ) async {
    try {
      final allComments = await remoteDatasource.fetchAllComments(page);
      return Right(allComments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
