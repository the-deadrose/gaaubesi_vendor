import 'package:equatable/equatable.dart';

abstract class VendorInfoEvent extends Equatable {
  const VendorInfoEvent();

  @override
  List<Object?> get props => [];
}

class FetchVendorInfoEvent extends VendorInfoEvent {
  const FetchVendorInfoEvent();

  @override
  List<Object?> get props => [];
}
