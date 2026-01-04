import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/app/comments/domain/entities/todays_comments_entity.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';

abstract class CommentsRepository {
  Future<Either<Failure, TodaysCommentsEntity>> fetchTodaysComments({
    required String page,
  });
}
