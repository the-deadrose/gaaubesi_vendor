import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/usecase/sidebar_usecase.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/bloc/sidebar_event.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/bloc/sidebar_state.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class SidebarBloc extends Bloc<SidebarEvent, SidebarState> {
  final SidebarUsecase _sidebarUsecase;

  SidebarBloc(this._sidebarUsecase) : super(SidebarInitialState()) {
    on<SidebarEvent>((event, emit) async {
      if (event is FetchSidebarDataEvent) {
        emit(SidebarLoadingState());
        final result = await _sidebarUsecase(NoParams());
        result.fold(
          (failure) => emit(SidebarErrorState(failure.toString())),
          (items) => emit(SidebarLoadedState(items)),
        );
      }
    });
  }
}
