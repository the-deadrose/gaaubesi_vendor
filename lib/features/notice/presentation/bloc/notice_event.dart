import 'package:equatable/equatable.dart';

abstract class NoticeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNoticeList extends NoticeEvent {
  @override
  List<Object?> get props => [];
}


class MarkNoticeAsReadEvent extends NoticeEvent {
  final String noticeId;

  MarkNoticeAsReadEvent({required this.noticeId});

  @override
  List<Object?> get props => [noticeId];
}