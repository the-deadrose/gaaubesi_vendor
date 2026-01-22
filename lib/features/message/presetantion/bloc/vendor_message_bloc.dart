// vendor_message_bloc.dart - Update this file
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/message/domain/entity/vendor_message_list_entity.dart';
import 'package:gaaubesi_vendor/features/message/domain/usecase/fetch_vendor_message_list_usecase.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/bloc/vendor_message_event.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/bloc/vendor_message_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VendorMessageBloc extends Bloc<VendorMessageEvent, VendorMessageState> {
  final FetchVendorMessageListUsecase fetchVendorMessageListUsecase;

  // Keep track of all loaded messages
  List<VendorMessageEntity> _allMessages = [];
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isFetching = false;

  VendorMessageBloc(this.fetchVendorMessageListUsecase)
    : super(VendorMessageInitial()) {
    on<FetchVendorMessageListEvent>((event, emit) async {
      // Reset state when fetching fresh list
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
          _allMessages = vendorMessageList.results;
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
          _allMessages.addAll(vendorMessageList.results);
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
                ), // Create new list to trigger UI update
              ),
            ),
          );
        },
      );
    });
  }

  // Helper methods if needed
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
}
