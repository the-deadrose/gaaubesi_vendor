import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
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
  bool _isFirstLoad = true;

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WarehouseOrderBloc>().add(
                        const FetchWarehouseOrderEvent(page: "1"),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WarehouseOrderLoadedState) {
            final warehouses = state.warehouseOrdersListEntity.warehouses;

            if (_isFirstLoad && warehouses.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _expandedWarehouseId = warehouses.first.id;
                  _isFirstLoad = false;
                });
              });
            }

            WareHouseOrdersEntity? selectedWarehouse;
            if (_expandedWarehouseId != null) {
              try {
                selectedWarehouse = warehouses.firstWhere(
                  (w) => w.id == _expandedWarehouseId,
                );
              } catch (e) {
                if (warehouses.isNotEmpty) {
                  selectedWarehouse = warehouses.first;
                  _expandedWarehouseId = warehouses.first.id;
                }
              }
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Warehouse:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Total Warehouses: ${warehouses.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey[50],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: warehouses.map((warehouse) {
                        final isSelected = _expandedWarehouseId == warehouse.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              '${warehouse.name} (${warehouse.ordersCount})',
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _expandedWarehouseId = selected
                                    ? warehouse.id
                                    : null;
                              });
                            },
                            selectedColor: Theme.of(context).primaryColor,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: selectedWarehouse != null
                      ? _buildWarehouseDetails(selectedWarehouse)
                      : _buildEmptyState(),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Select a warehouse to view orders',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseDetails(WareHouseOrdersEntity warehouse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: warehouse.orderIds.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: warehouse.orderIds.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemBuilder: (context, index) {
                          final orderId = warehouse.orderIds[index];

                          return ListTile(
                            onTap: () {
                              // Navigate to order detail when tapping on the title/whole tile
                              context.router.push(OrderDetailRoute(orderId: orderId));
                            },
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () {
                                // Navigate to order detail when tapping on title
                                context.router.push(OrderDetailRoute(orderId: orderId));
                              },
                              child: Text(
                                'ORD-$orderId',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                // Navigate to order detail when tapping on view button
                                context.router.push(OrderDetailRoute(orderId: orderId));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_shipping_outlined,
                                      size: 14,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'View',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : _buildNoOrdersSection(),
        ),
      ],
    );
  }

  Widget _buildNoOrdersSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 56, color: Colors.green[400]),
          const SizedBox(height: 16),
          const Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This warehouse has no pending orders',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}