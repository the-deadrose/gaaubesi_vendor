import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/usecase/vendor_info_usecase.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/usecase/vendor_update_usecase.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_event.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VendorInfoBloc extends Bloc<VendorInfoEvent, VendorInfoState> {
  final VendorInfoUsecase vendorInfoUsecase;
  final VendorUpdateUsecase vendorUpdateUsecase;

  VendorInfoBloc({
    required this.vendorInfoUsecase,
    required this.vendorUpdateUsecase,
  }) : super(VendorInfoInitialState()) {
    on<FetchVendorInfoEvent>((event, emit) async {
      emit(VendorInfoLoadingState());
      final result = await vendorInfoUsecase.call(NoParams());
      result.fold(
        (failure) {
          emit(VendorInfoErrorState(message: failure.message));
        },
        (vendorInfo) {
          emit(VendorInfoLoadedState(vendorInfo: vendorInfo));
        },
      );
    });

    on<UpdateVendorInfoEvent>((event, emit) async {
      emit(VendorInfoUpdatingState());

      final result = await vendorUpdateUsecase.call(
        VendorUpdateParams(
          address: event.address,
          nearestPickupPoint: event.nearestPickupPoint,
          latitude: event.latitude,
          longitude: event.longitude,
          profilePicture: event.profilePicture,
        ),
      );

      result.fold(
        (failure) {
          emit(VendorInfoUpdateErrorState(message: failure.message));
          add(FetchVendorInfoEvent());
        },
        (_) {
          emit(
            VendorInfoUpdatedState(
              message: 'Vendor information updated successfully',
            ),
          );
          add(FetchVendorInfoEvent());
        },
      );
    });
  }
}
