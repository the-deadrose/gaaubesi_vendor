import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/app/comments/data/datasource/comments_datasource.dart';
import 'package:gaaubesi_vendor/app/comments/domain/entities/todays_comments_entity.dart';
import 'package:gaaubesi_vendor/app/comments/domain/repository/comments_repository.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CommentsRepository)
class CommentsRepoImp implements CommentsRepository {
  final CommentsDatasource _remoteDataSource;
  CommentsRepoImp(this._remoteDataSource);


  @override
  Future<Either<Failure, TodaysCommentsEntity>> fetchTodaysComments({required String page}) async {
    try {
      final comments = await _remoteDataSource.fetchTodaysComments(page: page);
      return Right(comments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
