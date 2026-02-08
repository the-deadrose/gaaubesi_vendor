import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';

abstract class NoticeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NoticeListInitial extends NoticeState {}

class NoticeListLoading extends NoticeState {}

class NoticeListLoaded extends NoticeState {
  final NoticeListResponse noticeListResponse;

  NoticeListLoaded({required this.noticeListResponse});
  @override
  List<Object?> get props => [noticeListResponse];
}

class NoticeListError extends NoticeState {
  final String message;

  NoticeListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NoticeListPaginating extends NoticeState {}

class NoticeListPaginated extends NoticeState {
  final NoticeListResponse noticeListResponse;

  NoticeListPaginated({required this.noticeListResponse});
  @override
  List<Object?> get props => [noticeListResponse];
}

class NoticeListPaginationError extends NoticeState {
  final String message;

  NoticeListPaginationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NoticeListSearching extends NoticeState {}

class NoticeListSearchLoaded extends NoticeState {
  final NoticeListResponse noticeListResponse;

  NoticeListSearchLoaded({required this.noticeListResponse});
  @override
  List<Object?> get props => [noticeListResponse];
}

class NoticeListSearchError extends NoticeState {
  final String message;

  NoticeListSearchError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NoticeMarkAsReadSuccess extends NoticeState {
  final String noticeId;

  NoticeMarkAsReadSuccess({required this.noticeId});

  @override
  List<Object?> get props => [noticeId];
}

class NoticeMarkAsReadError extends NoticeState {
  final String message;

  NoticeMarkAsReadError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NoticeMarkAsReadLoading extends NoticeState {}
