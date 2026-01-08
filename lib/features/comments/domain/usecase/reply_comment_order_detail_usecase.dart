import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/repository/comments_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ReplyCommentOrderDetailUsecase
    implements UseCase<void, ReplyCommentOrderdetailParams> {
  final CommentsRepository _repository;

  ReplyCommentOrderDetailUsecase(this._repository);

  @override
  Future<Either<Failure, void>> call(
    ReplyCommentOrderdetailParams params,
  ) async {
    final result = await _repository.replyToCommentOrderDetail(
      commentId: params.commentId,
      comment: params.comment,
      reply: params.reply,
      commentType: params.commentType,
    );
    return result;
  }
}

class ReplyCommentOrderdetailParams {
  final String commentId;
  final String comment;
  final String reply;
  final String commentType;

  ReplyCommentOrderdetailParams({
    required this.commentId,
    required this.comment,
    required this.reply,
    required this.commentType,
  });
}
