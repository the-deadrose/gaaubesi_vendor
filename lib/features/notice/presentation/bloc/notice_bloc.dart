import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/notice/domain/usecase/notice_list_usecase.dart';
import 'package:gaaubesi_vendor/features/notice/domain/usecase/mark_read_notice_usecase.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';
import 'package:gaaubesi_vendor/features/notice/presentation/bloc/notice_event.dart';
import 'package:gaaubesi_vendor/features/notice/presentation/bloc/notice_state.dart';
import 'package:injectable/injectable.dart';

@injectable


class NoticeBloc extends Bloc<NoticeEvent, NoticeState> {
  final NoticeListUsecase _noticeListUsecase;
  final MarkReadNoticeUsecase _markReadNoticeUsecase;

  int _currentPage = 1;
  bool _isPaginating = false;
  NoticeListResponse? _cachedResponse;

  NoticeBloc(this._noticeListUsecase, this._markReadNoticeUsecase) : super(NoticeListInitial()) {
    on<FetchNoticeList>(_onFetchNoticeList);
    on<MarkNoticeAsReadEvent>(_onMarkNoticeAsRead);
  }

  Future<void> _onFetchNoticeList(
    FetchNoticeList event,
    Emitter<NoticeState> emit,
  ) async {
    // Pagination case
    if (_cachedResponse != null && _cachedResponse!.next != null) {
      if (_isPaginating) return;

      _isPaginating = true;
      debugPrint('[NoticeBloc] fetching next page=$_currentPage');
      emit(NoticeListPaginating());

      final result = await _noticeListUsecase(
        NoticeListParams(page: (++_currentPage).toString()),
      );

      result.fold(
        (failure) {
          _isPaginating = false;
          debugPrint(
            '[NoticeBloc] pagination error: ${failure.message} '
            'statusCode=${failure.statusCode}',
          );
          emit(
            NoticeListPaginationError(
              message: failure.message,
            ),
          );
        },
        (response) {
          debugPrint(
            '[NoticeBloc] pagination success count=${response.notices.length} '
            'next=${response.next}',
          );
          final mergedNotices = [
            ..._cachedResponse!.notices,
            ...response.notices,
          ];

          _cachedResponse = NoticeListResponse(
            notices: mergedNotices,
            count: response.count,
            next: response.next,
            previous: response.previous,
          );

          _isPaginating = false;
          emit(
            NoticeListPaginated(
              noticeListResponse: _cachedResponse!,
            ),
          );
        },
      );

      return;
    }

    // Initial load
    debugPrint('[NoticeBloc] fetching initial notice list');
    emit(NoticeListLoading());

    _currentPage = 1;
    _cachedResponse = null;

    final result = await _noticeListUsecase(
      NoticeListParams(page: _currentPage.toString()),
    );

    result.fold(
      (failure) {
        debugPrint(
          '[NoticeBloc] initial load error: ${failure.message} '
          'statusCode=${failure.statusCode}',
        );
        emit(
          NoticeListError(
            message: failure.message,
          ),
        );
      },
      (response) {
        debugPrint(
          '[NoticeBloc] initial load success count=${response.notices.length} '
          'next=${response.next}',
        );
        _cachedResponse = response;
        emit(
          NoticeListLoaded(
            noticeListResponse: response,
          ),
        );
      },
    );
  }

  Future<void> _onMarkNoticeAsRead(
    MarkNoticeAsReadEvent event,
    Emitter<NoticeState> emit,
  ) async {
    debugPrint('[NoticeBloc] mark as read requested noticeId=${event.noticeId}');
    emit(NoticeMarkAsReadLoading());

    final result = await _markReadNoticeUsecase(
      MarkReadNoticeUsecaseParams(noticeId: event.noticeId),
    );

    result.fold(
      (failure) {
        debugPrint(
          '[NoticeBloc] mark as read error: ${failure.message} '
          'statusCode=${failure.statusCode}',
        );
        emit(
          NoticeMarkAsReadError(
            message: failure.message,
          ),
        );
      },
      (success) {
        debugPrint('[NoticeBloc] mark as read success noticeId=${event.noticeId}');
        emit(
          NoticeMarkAsReadSuccess(
            noticeId: event.noticeId,
          ),
        );
      },
    );
  }
}
