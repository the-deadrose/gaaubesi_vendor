import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/all_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_filter_bottom_sheet.dart';

class AllOrdersTab extends BaseOrderTabView {
  const AllOrdersTab({super.key});

  @override
  State<AllOrdersTab> createState() => _AllOrdersTabState();
}

class _AllOrdersTabState extends BaseOrderTabViewState<AllOrdersTab> {
  @override
  void onLoadMore() {
    context.read<OrderBloc>().add(const OrderLoadMoreRequested());
  }

  @override
  Future<void> onRefresh() async {
    context.read<OrderBloc>().add(const OrderRefreshRequested());
  }

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      // Filter Button
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              OrderFilterConfig currentConfig = const OrderFilterConfig();

              if (state is OrderLoaded) {
                currentConfig = OrderFilterConfig(
                  sourceBranch: state.sourceBranch,
                  destinationBranch: state.destinationBranch,
                  startDate: state.startDate,
                  endDate: state.endDate,
                  status: state.currentStatus,
                );
              } else if (state is OrderLoadingMore) {
                currentConfig = OrderFilterConfig(
                  sourceBranch: state.sourceBranch,
                  destinationBranch: state.destinationBranch,
                  startDate: state.startDate,
                  endDate: state.endDate,
                  status: state.currentStatus,
                );
              }

              final theme = Theme.of(context);
              final hasActiveFilters = currentConfig.hasActiveFilters;

              return ElevatedButton.icon(
                onPressed: () async {
                  final result = await OrderFilterBottomSheet.show(
                    context: context,
                    initialConfig: currentConfig,
                    filterType: OrderFilterType.all,
                  );

                  if (result != null && context.mounted) {
                    context.read<OrderBloc>().add(
                      OrderAdvancedFilterChanged(
                        sourceBranch: result.sourceBranch,
                        destinationBranch: result.destinationBranch,
                        startDate: result.startDate,
                        endDate: result.endDate,
                        status: result.status,
                      ),
                    );
                  }
                },
                icon: Icon(
                  hasActiveFilters ? Icons.filter_alt : Icons.filter_list,
                  size: 18,
                ),
                label: Text(
                  hasActiveFilters
                      ? 'Filters (${currentConfig.activeFilterCount})'
                      : 'Filter Orders',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasActiveFilters
                      ? theme.primaryColor
                      : theme.brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  foregroundColor: hasActiveFilters
                      ? Colors.white
                      : theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  elevation: hasActiveFilters ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      const AllOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
