import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/warehouse_order_list_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class WarehouseOrderBloc
    extends Bloc<WarehouseOrderEvent, WarehouseOrderState> {
  final WarehouseOrderListUsecase warehouseOrderListUsecase;
  WarehouseOrderBloc({required this.warehouseOrderListUsecase})
    : super(WarehouseOrderInitialState()) {
    on<FetchWarehouseOrderEvent>((event, emit) async {
      emit(WarehouseOrderLoadingState());
      final result = await warehouseOrderListUsecase(
        WarehouseParams(page: event.page),
      );
      result.fold(
        (failure) => emit(WarehouseOrderErrorState(message: failure.message)),
        (wareHouseOrdersEntity) => emit(
          WarehouseOrderLoadedState(
            wareHouseOrdersEntity: wareHouseOrdersEntity,
          ),
        ),
      );
    });
  }
}
