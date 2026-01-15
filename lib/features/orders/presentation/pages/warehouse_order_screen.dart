import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/ware_house_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_state.dart';

class WarehouseOrderScreen extends StatefulWidget {
  const WarehouseOrderScreen({super.key});

  @override
  State<WarehouseOrderScreen> createState() => _WarehouseOrderScreenState();
}

class _WarehouseOrderScreenState extends State<WarehouseOrderScreen> {
  int? _expandedWarehouseId;

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
      appBar: AppBar(title: const Text('Warehouse Orders')),
      body: BlocBuilder<WarehouseOrderBloc, WarehouseOrderState>(
        builder: (context, state) {
          if (state is WarehouseOrderLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WarehouseOrderErrorState) {
            return Center(child: Text(state.message));
          }

          if (state is WarehouseOrderLoadedState) {
            final warehouses = state.warehouseOrdersListEntity.warehouses;

            return Column(
              children: [
                // Warehouse Chips Section
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: warehouses.map((warehouse) {
                      return ChoiceChip(
                        label: Text(
                          warehouse.name,
                          style: TextStyle(
                            color: _expandedWarehouseId == warehouse.id
                                ? Colors.white
                                : null,
                          ),
                        ),
                        selected: _expandedWarehouseId == warehouse.id,
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey[200],
                        onSelected: (selected) {
                          setState(() {
                            _expandedWarehouseId = selected
                                ? warehouse.id
                                : null;
                          });
                        },
                        avatar: CircleAvatar(
                          backgroundColor: _expandedWarehouseId == warehouse.id
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          radius: 12,
                          child: Text(
                            warehouse.ordersCount.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: _expandedWarehouseId == warehouse.id
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Divider
                const Divider(thickness: 1),

                // Expanded Warehouse Details
                Expanded(
                  child: _expandedWarehouseId != null
                      ? _buildWarehouseDetails(
                          warehouses.firstWhere(
                            (w) => w.id == _expandedWarehouseId,
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Select a warehouse to view orders',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildWarehouseDetails(WareHouseOrdersEntity warehouse) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warehouse Header
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        warehouse.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${warehouse.ordersCount} Orders',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Code: ${warehouse.code}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Orders List
          Expanded(
            child: Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: warehouse.ordersCount,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        // Generate order IDs based on warehouse code and index
                        final orderId = '${warehouse.code}-${index + 1}';

                        return ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text(
                            'Order #$orderId',
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            'Status: Processing',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to order details
                            print('Tapped on order $orderId');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
