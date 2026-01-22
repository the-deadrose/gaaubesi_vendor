import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/message/domain/entity/vendor_message_list_entity.dart';

class VendorMessageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VendorMessageInitial extends VendorMessageState {}

class VendorMessageLoading extends VendorMessageState {}

class VendorMessageEmpty extends VendorMessageState {}

class VendorMessageError extends VendorMessageState {
  final String message;

  VendorMessageError({required this.message});

  @override
  List<Object?> get props => [message];
}

class VendorMessageLoaded extends VendorMessageState {
  final VendorMessageListEntity vendorMessageList;
  VendorMessageLoaded({required this.vendorMessageList});

  @override
  List<Object?> get props => [vendorMessageList];
}

class VendorMessagePaginating extends VendorMessageState {}

class VendorMessagePaginationError extends VendorMessageState {
  final String message;

  VendorMessagePaginationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class VendorMessagePaginated extends VendorMessageState {
  final VendorMessageListEntity vendorMessageList;
  VendorMessagePaginated({required this.vendorMessageList});

  @override
  List<Object?> get props => [vendorMessageList];
}
