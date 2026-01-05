// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentsResponse _$CommentsResponseFromJson(Map<String, dynamic> json) =>
    CommentsResponse(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] == null
          ? null
          : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentsResponseToJson(CommentsResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': ?instance.next,
      'previous': ?instance.previous,
      'results': ?instance.results?.map((e) => e.toJson()).toList(),
      'metadata': ?instance.metadata?.toJson(),
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: (json['id'] as num).toInt(),
  orderId: json['order_id'] as String?,
  orderLink: json['order_link'] as String?,
  comments: json['comments'] as String?,
  commentScope: json['comment_scope'] as String?,
  commentType: json['comment_type'] as String?,
  commentTypeDisplay: json['comment_type_display'] as String?,
  status: json['status'] as String?,
  statusDisplay: json['status_display'] as String?,
  addedByName: json['added_by_name'] as String?,
  addedByRole: json['added_by_role'] as String?,
  createdOn: json['created_on'] as String?,
  createdOnFormatted: json['created_on_formatted'] as String?,
  branchName: json['branch_name'] as String?,
  hasChildComments: json['has_child_comments'] as bool,
  childComments: (json['child_comments'] as List<dynamic>?)
      ?.map((e) => ChildComment.fromJson(e as Map<String, dynamic>))
      .toList(),
  canReply: json['can_reply'] as bool,
  isImportant: json['is_important'] as bool,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'order_id': ?instance.orderId,
  'order_link': ?instance.orderLink,
  'comments': ?instance.comments,
  'comment_scope': ?instance.commentScope,
  'comment_type': ?instance.commentType,
  'comment_type_display': ?instance.commentTypeDisplay,
  'status': ?instance.status,
  'status_display': ?instance.statusDisplay,
  'added_by_name': ?instance.addedByName,
  'added_by_role': ?instance.addedByRole,
  'created_on': ?instance.createdOn,
  'created_on_formatted': ?instance.createdOnFormatted,
  'branch_name': ?instance.branchName,
  'has_child_comments': instance.hasChildComments,
  'child_comments': ?instance.childComments?.map((e) => e.toJson()).toList(),
  'can_reply': instance.canReply,
  'is_important': instance.isImportant,
};

ChildComment _$ChildCommentFromJson(Map<String, dynamic> json) => ChildComment(
  id: (json['id'] as num).toInt(),
  comments: json['comments'] as String?,
  addedByName: json['added_by_name'] as String?,
  addedByRole: json['added_by_role'] as String?,
  createdOnFormatted: json['created_on_formatted'] as String?,
  commentScope: json['comment_scope'] as String?,
);

Map<String, dynamic> _$ChildCommentToJson(ChildComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'comments': ?instance.comments,
      'added_by_name': ?instance.addedByName,
      'added_by_role': ?instance.addedByRole,
      'created_on_formatted': ?instance.createdOnFormatted,
      'comment_scope': ?instance.commentScope,
    };

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
  todayMode: json['today_mode'] as bool,
  totalCount: (json['total_count'] as num).toInt(),
  filtersApplied: json['filters_applied'] == null
      ? null
      : FiltersApplied.fromJson(
          json['filters_applied'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
  'today_mode': instance.todayMode,
  'total_count': instance.totalCount,
  'filters_applied': ?instance.filtersApplied?.toJson(),
};

FiltersApplied _$FiltersAppliedFromJson(Map<String, dynamic> json) =>
    FiltersApplied(
      branch: json['branch'] as String,
      status: json['status'] as String,
      keyword: json['keyword'] as String,
    );

Map<String, dynamic> _$FiltersAppliedToJson(FiltersApplied instance) =>
    <String, dynamic>{
      'branch': instance.branch,
      'status': instance.status,
      'keyword': instance.keyword,
    };
