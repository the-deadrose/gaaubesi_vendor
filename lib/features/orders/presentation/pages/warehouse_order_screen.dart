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
      const FetchWarehouseOrderEvent(page: '1'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<WarehouseOrderBloc, WarehouseOrderState>(
      builder: (context, state) {
        if (state is WarehouseOrderLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WarehouseOrderErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      context.read<WarehouseOrderBloc>().add(
                        const FetchWarehouseOrderEvent(page: '1'),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! WarehouseOrderLoadedState) {
          return const SizedBox();
        }

        final warehouses = state.warehouseOrdersListEntity.warehouses;

        if (_isFirstLoad && warehouses.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _expandedWarehouseId = warehouses.first.id;
              _isFirstLoad = false;
            });
          });
        }

        final selectedWarehouse = _resolveSelectedWarehouse(warehouses);

        return ColoredBox(
          color: colorScheme.surface,
          child: Column(
            children: [
              _buildTopHeader(warehouses.length, theme, colorScheme),
              _buildWarehouseSelector(warehouses, colorScheme),
              Expanded(
                child: selectedWarehouse == null
                    ? _buildEmptyState()
                    : _buildWarehouseDetails(selectedWarehouse),
              ),
            ],
          ),
        );
      },
    );
  }

  WareHouseOrdersEntity? _resolveSelectedWarehouse(
    List<WareHouseOrdersEntity> warehouses,
  ) {
    if (_expandedWarehouseId == null || warehouses.isEmpty) {
      return null;
    }

    for (final warehouse in warehouses) {
      if (warehouse.id == _expandedWarehouseId) {
        return warehouse;
      }
    }

    _expandedWarehouseId = warehouses.first.id;
    return warehouses.first;
  }

  Widget _buildTopHeader(
    int warehouseCount,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Warehouses',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$warehouseCount total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelector(
    List<WareHouseOrdersEntity> warehouses,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: warehouses.map((warehouse) {
            final isSelected = _expandedWarehouseId == warehouse.id;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    _expandedWarehouseId = warehouse.id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        warehouse.name,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${warehouse.ordersCount}',
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  warehouse.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${warehouse.orderIds.length} orders',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: warehouse.orderIds.isEmpty
              ? _buildNoOrdersSection()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                  itemCount: warehouse.orderIds.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final orderId = warehouse.orderIds[index];
                    return InkWell(
                      onTap: () {
                        context.router.push(OrderDetailRoute(orderId: orderId));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.22),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ORD-$orderId',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap to view details',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.62,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colorScheme.onSurface.withValues(alpha: 0.45),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
