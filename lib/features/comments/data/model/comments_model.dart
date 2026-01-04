import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comments_model.g.dart';

@JsonSerializable()
class CommentsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Comment>? results;
  final Metadata? metadata;

  const CommentsResponse({
    required this.count,
    this.next,
    this.previous,
    this.results,
    this.metadata,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CommentsResponseToJson(this);

  CommentsResponseEntity toEntity() => CommentsResponseEntity(
    count: count,
    next: next,
    previous: previous,
    results: results?.map((e) => e.toEntity()).toList() ?? [],
    metadata: metadata?.toEntity(),
  );
}

@JsonSerializable()
class Comment {
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
  final List<ChildComment>? childComments;
  final bool canReply;
  final bool isImportant;

  const Comment({
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

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  CommentEntity toEntity() => CommentEntity(
    id: id,
    orderId: orderId,
    orderLink: orderLink,
    comments: comments,
    commentScope: commentScope,
    commentType: commentType,
    commentTypeDisplay: commentTypeDisplay,
    status: status,
    statusDisplay: statusDisplay,
    addedByName: addedByName,
    addedByRole: addedByRole,
    createdOn: createdOn,
    createdOnFormatted: createdOnFormatted,
    branchName: branchName,
    hasChildComments: hasChildComments,
    childComments: childComments?.map((e) => e.toEntity()).toList() ?? [],
    canReply: canReply,
    isImportant: isImportant,
  );
}

@JsonSerializable()
class ChildComment {
  final int id;
  final String comments;
  final String addedByName;
  final String addedByRole;
  final String createdOnFormatted;
  final String commentScope;

  const ChildComment({
    required this.id,
    required this.comments,
    required this.addedByName,
    required this.addedByRole,
    required this.createdOnFormatted,
    required this.commentScope,
  });

  factory ChildComment.fromJson(Map<String, dynamic> json) =>
      _$ChildCommentFromJson(json);

  Map<String, dynamic> toJson() => _$ChildCommentToJson(this);

  ChildCommentEntity toEntity() => ChildCommentEntity(
    id: id,
    comments: comments,
    addedByName: addedByName,
    addedByRole: addedByRole,
    createdOnFormatted: createdOnFormatted,
    commentScope: commentScope,
  );
}

@JsonSerializable()
class Metadata {
  final bool todayMode;
  final int totalCount;
  final FiltersApplied? filtersApplied;

  const Metadata({
    required this.todayMode,
    required this.totalCount,
    this.filtersApplied,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);

  MetadataEntity toEntity() => MetadataEntity(
    todayMode: todayMode,
    totalCount: totalCount,
    filtersApplied: filtersApplied?.toEntity() ?? FiltersAppliedEntity(
      branch: '',
      status: '',
      keyword: '',
    ),
  );
}

@JsonSerializable()
class FiltersApplied {
  final String branch;
  final String status;
  final String keyword;

  const FiltersApplied({
    required this.branch,
    required this.status,
    required this.keyword,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) =>
      _$FiltersAppliedFromJson(json);

  Map<String, dynamic> toJson() => _$FiltersAppliedToJson(this);

  FiltersAppliedEntity toEntity() => FiltersAppliedEntity(
    branch: branch,
    status: status,
    keyword: keyword,
  );
}