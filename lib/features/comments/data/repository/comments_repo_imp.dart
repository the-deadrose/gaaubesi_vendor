import 'package:fpdart/fpdart.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:injectable/injectable.dart';
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
    // try {
      final todaysComments = await remoteDatasource.fetchTodaysComments(page);
      return Right(todaysComments);
    // } on ServerException catch (e) {
    //   return Left(ServerFailure(e.message));
    // } catch (e) {
    //   return Left(ServerFailure('An unexpected error occurred'));
    // }
  }

  @override
  Future<Either<ServerFailure, CommentsResponseEntity>> allComments(
    String page,
  ) async {
    // try {
      final allComments = await remoteDatasource.fetchAllComments(page);
      return Right(allComments);
    // } on ServerException catch (e) {
    //   return Left(ServerFailure(e.message));
    // } catch (e) {
    //   return Left(ServerFailure('An unexpected error occurred'));
    // }
  }

  @override
  Future<Either<ServerFailure, CommentsResponseEntity>> filteredComments({
    required String page,
    String? status,
    String? startDate,
    String? endDate,
    String? searchId,
  }) async {
    final filteredComments = await remoteDatasource.fetchCommentsFiltered(
      page: page,
      status: status,
      startDate: startDate,
      endDate: endDate,
      searchId: searchId,
    );
    return Right(filteredComments);
  }

  @override
  Future<Either<ServerFailure, void>> replyToComment({
    required String commentId,
    required String comment,
  }) async {
    try {
      await remoteDatasource.replyToComment(
        commentId: commentId,
        comment: comment,
      );
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint('[COMMENTS_REPO] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[COMMENTS_REPO] Unexpected error: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }


}
