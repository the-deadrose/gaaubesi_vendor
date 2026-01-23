import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';

class VendorInfoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VendorInfoInitialState extends VendorInfoState {}

class VendorInfoLoadingState extends VendorInfoState {}

class VendorInfoLoadedState extends VendorInfoState {
  final VendorInfoEntity vendorInfo;
  VendorInfoLoadedState({required this.vendorInfo});
  @override
  List<Object?> get props => [vendorInfo];
}

class VendorInfoErrorState extends VendorInfoState {
  final String message;
  VendorInfoErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}
