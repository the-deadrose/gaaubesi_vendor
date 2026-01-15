import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_state.dart';

class WarehouseOrderScreen extends StatefulWidget {
  const WarehouseOrderScreen({super.key});

  @override
  State<WarehouseOrderScreen> createState() => _WarehouseOrderScreenState();
}

class _WarehouseOrderScreenState extends State<WarehouseOrderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WarehouseOrderBloc>().add(
          const FetchWarehouseOrderEvent(page: "1"),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WarehouseOrderBloc, WarehouseOrderState>(
        builder: (context, state) {
          if (state is WarehouseOrderLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WarehouseOrderErrorState) {
            return Center(child: Text(state.message));
          }

          if (state is WarehouseOrderLoadedState) {
            final warehouse = state.wareHouseOrdersEntity;

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _WarehouseExpansionTile(
                  warehouseName: warehouse.name,
                  warehouseCode: warehouse.code,
                  ordersCount: warehouse.ordersCount,
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
class _WarehouseExpansionTile extends StatelessWidget {
  final String warehouseName;
  final String warehouseCode;
  final int ordersCount;

  const _WarehouseExpansionTile({
    required this.warehouseName,
    required this.warehouseCode,
    required this.ordersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          warehouseName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "Code: $warehouseCode • Orders: $ordersCount",
          style: const TextStyle(fontSize: 13),
        ),
        children: List.generate(
          ordersCount,
          (index) => _OrderItem(
            orderId: "ORD-${index + 1}",
          ),
        ),
      ),
    );
  }
}
class _OrderItem extends StatelessWidget {
  final String orderId;

  const _OrderItem({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, size: 18),
          const SizedBox(width: 8),
          Text(
            orderId,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
