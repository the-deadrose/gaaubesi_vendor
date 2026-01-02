import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/returned_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_filter_bottom_sheet.dart';

class ReturnedOrdersTab extends BaseOrderTabView {
  const ReturnedOrdersTab({super.key});

  @override
  State<ReturnedOrdersTab> createState() => _ReturnedOrdersTabState();
}

class _ReturnedOrdersTabState extends BaseOrderTabViewState<ReturnedOrdersTab> {
  @override
  void onLoadMore() {
    context.read<ReturnedOrderBloc>().add(
      const ReturnedOrderLoadMoreRequested(),
    );
  }

  @override
  Future<void> onRefresh() async {
    context.read<ReturnedOrderBloc>().add(
      const ReturnedOrderRefreshRequested(),
    );
  }

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      // Filter Button
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: BlocBuilder<ReturnedOrderBloc, ReturnedOrderState>(
            builder: (context, state) {
              OrderFilterConfig currentConfig = const OrderFilterConfig();

              if (state is ReturnedOrderLoaded) {
                currentConfig = OrderFilterConfig(
                  destination: state.destination,
                  startDate: state.startDate,
                  endDate: state.endDate,
                  receiverSearch: state.receiverSearch,
                  minCharge: state.minCharge,
                  maxCharge: state.maxCharge,
                );
              } else if (state is ReturnedOrderLoadingMore) {
                currentConfig = OrderFilterConfig(
                  destination: state.destination,
                  startDate: state.startDate,
                  endDate: state.endDate,
                  receiverSearch: state.receiverSearch,
                  minCharge: state.minCharge,
                  maxCharge: state.maxCharge,
                );
              }

              final theme = Theme.of(context);
              final hasActiveFilters = currentConfig.hasActiveFilters;

              return ElevatedButton.icon(
                onPressed: () async {
                  final result = await OrderFilterBottomSheet.show(
                    context: context,
                    initialConfig: currentConfig,
                    filterType: OrderFilterType.returned,
                  );

                  if (result != null && context.mounted) {
                    context.read<ReturnedOrderBloc>().add(
                      ReturnedOrderFilterChanged(
                        destination: result.destination,
                        startDate: result.startDate,
                        endDate: result.endDate,
                        receiverSearch: result.receiverSearch,
                        minCharge: result.minCharge,
                        maxCharge: result.maxCharge,
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
      const ReturnedOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
