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
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
      'metadata': instance.metadata,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: (json['id'] as num).toInt(),
  orderId: json['orderId'] as String,
  orderLink: json['orderLink'] as String,
  comments: json['comments'] as String,
  commentScope: json['commentScope'] as String,
  commentType: json['commentType'] as String,
  commentTypeDisplay: json['commentTypeDisplay'] as String,
  status: json['status'] as String?,
  statusDisplay: json['statusDisplay'] as String?,
  addedByName: json['addedByName'] as String,
  addedByRole: json['addedByRole'] as String,
  createdOn: json['createdOn'] as String,
  createdOnFormatted: json['createdOnFormatted'] as String,
  branchName: json['branchName'] as String,
  hasChildComments: json['hasChildComments'] as bool,
  childComments: (json['childComments'] as List<dynamic>?)
      ?.map((e) => ChildComment.fromJson(e as Map<String, dynamic>))
      .toList(),
  canReply: json['canReply'] as bool,
  isImportant: json['isImportant'] as bool,
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'orderLink': instance.orderLink,
  'comments': instance.comments,
  'commentScope': instance.commentScope,
  'commentType': instance.commentType,
  'commentTypeDisplay': instance.commentTypeDisplay,
  'status': instance.status,
  'statusDisplay': instance.statusDisplay,
  'addedByName': instance.addedByName,
  'addedByRole': instance.addedByRole,
  'createdOn': instance.createdOn,
  'createdOnFormatted': instance.createdOnFormatted,
  'branchName': instance.branchName,
  'hasChildComments': instance.hasChildComments,
  'childComments': instance.childComments,
  'canReply': instance.canReply,
  'isImportant': instance.isImportant,
};

ChildComment _$ChildCommentFromJson(Map<String, dynamic> json) => ChildComment(
  id: (json['id'] as num).toInt(),
  comments: json['comments'] as String,
  addedByName: json['addedByName'] as String,
  addedByRole: json['addedByRole'] as String,
  createdOnFormatted: json['createdOnFormatted'] as String,
  commentScope: json['commentScope'] as String,
);

Map<String, dynamic> _$ChildCommentToJson(ChildComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'comments': instance.comments,
      'addedByName': instance.addedByName,
      'addedByRole': instance.addedByRole,
      'createdOnFormatted': instance.createdOnFormatted,
      'commentScope': instance.commentScope,
    };

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
  todayMode: json['todayMode'] as bool,
  totalCount: (json['totalCount'] as num).toInt(),
  filtersApplied: json['filtersApplied'] == null
      ? null
      : FiltersApplied.fromJson(json['filtersApplied'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
  'todayMode': instance.todayMode,
  'totalCount': instance.totalCount,
  'filtersApplied': instance.filtersApplied,
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
