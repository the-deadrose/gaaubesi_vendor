import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/usecase/vendor_info_usecase.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_event.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_state.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class VendorInfoBloc extends Bloc<VendorInfoEvent, VendorInfoState> {
  final VendorInfoUsecase vendorInfoUsecase;

  VendorInfoBloc({required this.vendorInfoUsecase})
    : super(VendorInfoInitialState()) {
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
  }
}
