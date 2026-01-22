import 'package:equatable/equatable.dart';

abstract class VendorMessageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchVendorMessageListEvent extends VendorMessageEvent {
  final String page;

  FetchVendorMessageListEvent({required this.page});

  @override
  List<Object?> get props => [page];
}

class FetchVendorMessageListPaginationEvent extends VendorMessageEvent {
  final String page;

  FetchVendorMessageListPaginationEvent({required this.page});

  @override
  List<Object?> get props => [page];
}