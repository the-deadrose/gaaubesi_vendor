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
      emit(NoticeListPaginating());

      final result = await _noticeListUsecase(
        NoticeListParams(page: (++_currentPage).toString()),
      );

      result.fold(
        (failure) {
          _isPaginating = false;
          emit(
            NoticeListPaginationError(
              message: failure.message,
            ),
          );
        },
        (response) {
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
    emit(NoticeListLoading());

    _currentPage = 1;
    _cachedResponse = null;

    final result = await _noticeListUsecase(
      NoticeListParams(page: _currentPage.toString()),
    );

    result.fold(
      (failure) {
        emit(
          NoticeListError(
            message: failure.message,
          ),
        );
      },
      (response) {
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
    emit(NoticeMarkAsReadLoading());

    final result = await _markReadNoticeUsecase(
      MarkReadNoticeUsecaseParams(noticeId: event.noticeId),
    );

    result.fold(
      (failure) {
        emit(
          NoticeMarkAsReadError(
            message: failure.message,
          ),
        );
      },
      (success) {
        emit(
          NoticeMarkAsReadSuccess(
            noticeId: event.noticeId,
          ),
        );
      },
    );
  }
}
