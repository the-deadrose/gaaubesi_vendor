// vendor_message_bloc.dart - Update this file
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/message/domain/entity/vendor_message_list_entity.dart';
import 'package:gaaubesi_vendor/features/message/domain/usecase/fetch_vendor_message_list_usecase.dart';
import 'package:gaaubesi_vendor/features/message/domain/usecase/mark_as_read_message_usecase.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/bloc/vendor_message_event.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/bloc/vendor_message_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VendorMessageBloc extends Bloc<VendorMessageEvent, VendorMessageState> {
  final FetchVendorMessageListUsecase fetchVendorMessageListUsecase;
  final MarkAsReadMessageUsecase markAsReadMessageUsecase;

  List<VendorMessageEntity> _allMessages = [];
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isFetching = false;

  VendorMessageBloc(
    this.fetchVendorMessageListUsecase,
    this.markAsReadMessageUsecase,
  ) : super(VendorMessageInitial()) {
    on<FetchVendorMessageListEvent>((event, emit) async {
      _allMessages = [];
      _currentPage = 1;
      _hasMore = true;
      _isFetching = true;

      emit(VendorMessageLoading());

      final result = await fetchVendorMessageListUsecase(
        FetchVendorMessageListParams(page: "1"),
      );

      _isFetching = false;

      result.fold(
        (failure) => emit(VendorMessageError(message: failure.message)),
        (vendorMessageList) {
          _allMessages = List<VendorMessageEntity>.from(vendorMessageList.results);
          _hasMore = vendorMessageList.next != null;

          if (_allMessages.isEmpty) {
            emit(VendorMessageEmpty());
          } else {
            emit(
              VendorMessageLoaded(
                vendorMessageList: VendorMessageListEntity(
                  count: vendorMessageList.count,
                  next: vendorMessageList.next,
                  previous: vendorMessageList.previous,
                  results: _allMessages,
                ),
              ),
            );
          }
        },
      );
    });

    on<FetchVendorMessageListPaginationEvent>((event, emit) async {
      if (_isFetching || !_hasMore) return;

      _isFetching = true;
      emit(VendorMessagePaginating());

      final result = await fetchVendorMessageListUsecase(
        FetchVendorMessageListParams(page: event.page),
      );

      _isFetching = false;

      result.fold(
        (failure) =>
            emit(VendorMessagePaginationError(message: failure.message)),
        (vendorMessageList) {
          _allMessages.addAll(List<VendorMessageEntity>.from(vendorMessageList.results));
          _hasMore = vendorMessageList.next != null;
          _currentPage = int.tryParse(event.page) ?? (_currentPage + 1);

          emit(
            VendorMessagePaginated(
              vendorMessageList: VendorMessageListEntity(
                count: vendorMessageList.count,
                next: vendorMessageList.next,
                previous: vendorMessageList.previous,
                results: List.from(
                  _allMessages,
                ),
              ),
            ),
          );
        },
      );
    });

    on<MarkMessageAsReadEvent>((event, emit) async {
      emit(VendorMessageMarkAsReadLoading());

      final result = await markAsReadMessageUsecase(
        MarkAsReadMessageUsecaseParams(messageId: event.messageId),
      );

      result.fold(
        (failure) => emit(VendorMessageMarkAsReadError(message: failure.message)),
        (_) {
          // Update the local messages list to mark as read
          for (int i = 0; i < _allMessages.length; i++) {
            if (_allMessages[i].id.toString() == event.messageId) {
              _allMessages[i] = _allMessages[i].copyWith(isRead: true);
              break;
            }
          }
          
          emit(
            VendorMessageLoaded(
              vendorMessageList: VendorMessageListEntity(
                count: _allMessages.length,
                results: List.from(_allMessages),
              ),
            ),
          );
        },
      );
    });
  }

  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
}
