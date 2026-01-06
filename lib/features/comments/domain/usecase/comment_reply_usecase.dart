import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/repository/comments_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CommentReplyUsecase implements UseCase<void, CommentReplyParams> {
  final CommentsRepository _repository;

  CommentReplyUsecase(this._repository);

  @override
  Future<Either<Failure, void>> call(CommentReplyParams params) async {
    final result = await _repository.replyToComment(
      commentId: params.commentId,
      comment: params.comment,
    );
    return result;
  }
}

class CommentReplyParams {
  final String commentId;
  final String comment;

  CommentReplyParams({required this.commentId, required this.comment});
}
