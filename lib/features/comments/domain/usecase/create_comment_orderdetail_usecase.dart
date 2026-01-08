import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/repository/comments_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateCommentOrderdetailUsecase
    implements UseCase<void, CreateCommentOrderdetailParams> {
  final CommentsRepository _repository;

  CreateCommentOrderdetailUsecase(this._repository);

  @override
  Future<Either<Failure, void>> call(
    CreateCommentOrderdetailParams params,
  ) async {
    final result = await _repository.createCommentOrderDetail(
      commentId: params.commentId,
      comment: params.comment,
      commentType: params.commentType,
    );
    return result;
  }
}

class CreateCommentOrderdetailParams {
  final String commentId;
  final String comment;
  final String commentType;

  CreateCommentOrderdetailParams({
    required this.commentId,
    required this.comment,
    required this.commentType,
  });
}
