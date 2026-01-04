import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';

abstract class CommentsRepository {
  Future<Either<Failure, CommentsResponseEntity>> todaysComments(String page);
  Future<Either<Failure, CommentsResponseEntity>> allComments(String page);
}
