import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comments_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
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

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Comment {
  final int id;
  @JsonKey(name: 'order_id')
  final String? orderId;
  @JsonKey(name: 'order_link')
  final String? orderLink;
  final String? comments;
  @JsonKey(name: 'comment_scope')
  final String? commentScope;
  @JsonKey(name: 'comment_type')
  final String? commentType;
  @JsonKey(name: 'comment_type_display')
  final String? commentTypeDisplay;
  final String? status;
  @JsonKey(name: 'status_display')
  final String? statusDisplay;
  @JsonKey(name: 'added_by_name')
  final String? addedByName;
  @JsonKey(name: 'added_by_role')
  final String? addedByRole;
  @JsonKey(name: 'created_on')
  final String? createdOn;
  @JsonKey(name: 'created_on_formatted')
  final String? createdOnFormatted;
  @JsonKey(name: 'branch_name')
  final String? branchName;
  @JsonKey(name: 'has_child_comments')
  final bool hasChildComments;
  @JsonKey(name: 'child_comments')
  final List<ChildComment>? childComments;
  @JsonKey(name: 'can_reply')
  final bool canReply;
  @JsonKey(name: 'is_important')
  final bool isImportant;

  const Comment({
    required this.id,
    this.orderId,
    this.orderLink,
    this.comments,
    this.commentScope,
    this.commentType,
    this.commentTypeDisplay,
    this.status,
    this.statusDisplay,
    this.addedByName,
    this.addedByRole,
    this.createdOn,
    this.createdOnFormatted,
    this.branchName,
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
    orderId: orderId ?? '',
    orderLink: orderLink ?? '',
    comments: comments ?? '',
    commentScope: commentScope ?? '',
    commentType: commentType ?? '',
    commentTypeDisplay: commentTypeDisplay ?? '',
    status: status,
    statusDisplay: statusDisplay,
    addedByName: addedByName ?? '',
    addedByRole: addedByRole ?? '',
    createdOn: createdOn ?? '',
    createdOnFormatted: createdOnFormatted ?? '',
    branchName: branchName ?? '',
    hasChildComments: hasChildComments,
    childComments: childComments?.map((e) => e.toEntity()).toList() ?? [],
    canReply: canReply,
    isImportant: isImportant,
  );
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ChildComment {
  final int id;
  final String? comments;
  @JsonKey(name: 'added_by_name')
  final String? addedByName;
  @JsonKey(name: 'added_by_role')
  final String? addedByRole;
  @JsonKey(name: 'created_on_formatted')
  final String? createdOnFormatted;
  @JsonKey(name: 'comment_scope')
  final String? commentScope;

  const ChildComment({
    required this.id,
    this.comments,
    this.addedByName,
    this.addedByRole,
    this.createdOnFormatted,
    this.commentScope,
  });

  factory ChildComment.fromJson(Map<String, dynamic> json) =>
      _$ChildCommentFromJson(json);

  Map<String, dynamic> toJson() => _$ChildCommentToJson(this);

  ChildCommentEntity toEntity() => ChildCommentEntity(
    id: id,
    comments: comments ?? '',
    addedByName: addedByName ?? '',
    addedByRole: addedByRole ?? '',
    createdOnFormatted: createdOnFormatted ?? '',
    commentScope: commentScope ?? '',
  );
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Metadata {
  @JsonKey(name: 'today_mode')
  final bool todayMode;
  @JsonKey(name: 'total_count')
  final int totalCount;
  @JsonKey(name: 'filters_applied')
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

@JsonSerializable(explicitToJson: true, includeIfNull: false)
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