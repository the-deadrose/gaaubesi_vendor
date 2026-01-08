import 'package:equatable/equatable.dart';

class CommentsResponseEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<CommentEntity>? results;
  final MetadataEntity? metadata;

  const CommentsResponseEntity({
    required this.count,
    this.next,
    this.previous,
    this.results,
    this.metadata,
  });

  @override
  List<Object?> get props => [count, next, previous, results, metadata];
}

class CommentEntity extends Equatable {
  final int id;
  final String orderId;
  final String orderLink;
  final String comments;
  final String commentScope;
  final String commentType;
  final String commentTypeDisplay;
  final String? status;
  final String? statusDisplay;
  final String addedByName;
  final String addedByRole;
  final String createdOn;
  final String createdOnFormatted;
  final String branchName;
  final bool hasChildComments;
  final List<ChildCommentEntity>? childComments;
  final bool canReply;
  final bool isImportant;

  const CommentEntity({
    required this.id,
    required this.orderId,
    required this.orderLink,
    required this.comments,
    required this.commentScope,
    required this.commentType,
    required this.commentTypeDisplay,
    this.status,
    this.statusDisplay,
    required this.addedByName,
    required this.addedByRole,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.branchName,
    required this.hasChildComments,
    this.childComments,
    required this.canReply,
    required this.isImportant,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        orderLink,
        comments,
        commentScope,
        commentType,
        commentTypeDisplay,
        status,
        statusDisplay,
        addedByName,
        addedByRole,
        createdOn,
        createdOnFormatted,
        branchName,
        hasChildComments,
        childComments,
        canReply,
        isImportant,
      ];
}

class ChildCommentEntity extends Equatable {
  final int id;
  final String comments;
  final String addedByName;
  final String addedByRole;
  final String createdOnFormatted;
  final String commentScope;

  const ChildCommentEntity({
    required this.id,
    required this.comments,
    required this.addedByName,
    required this.addedByRole,
    required this.createdOnFormatted,
    required this.commentScope,
  });

  @override
  List<Object?> get props => [
        id,
        comments,
        addedByName,
        addedByRole,
        createdOnFormatted,
        commentScope,
      ];
}

class MetadataEntity extends Equatable {
  final bool todayMode;
  final int totalCount;
  final FiltersAppliedEntity? filtersApplied;

  const MetadataEntity({
    required this.todayMode,
    required this.totalCount,
    this.filtersApplied,
  });

  @override
  List<Object?> get props => [todayMode, totalCount, filtersApplied];
}

class FiltersAppliedEntity extends Equatable {
  final String branch;
  final String status;
  final String keyword;

  const FiltersAppliedEntity({
    required this.branch,
    required this.status,
    required this.keyword,
  });

  @override
  List<Object?> get props => [branch, status, keyword];
}

