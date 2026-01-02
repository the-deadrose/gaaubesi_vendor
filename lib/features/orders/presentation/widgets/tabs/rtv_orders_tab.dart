import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/slivers/rtv_order_list_sliver.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/tabs/base_order_tab_view.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/order_filter_bottom_sheet.dart';

class RtvOrdersTab extends BaseOrderTabView {
  const RtvOrdersTab({super.key});

  @override
  State<RtvOrdersTab> createState() => _RtvOrdersTabState();
}

class _RtvOrdersTabState extends BaseOrderTabViewState<RtvOrdersTab> {
  @override
  void onLoadMore() {
    context.read<RtvOrderBloc>().add(const RtvOrderLoadMoreRequested());
  }

  @override
  Future<void> onRefresh() async {
    context.read<RtvOrderBloc>().add(const RtvOrderRefreshRequested());
  }

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return [
      // Filter Button
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: BlocBuilder<RtvOrderBloc, RtvOrderState>(
            builder: (context, state) {
              OrderFilterConfig currentConfig = const OrderFilterConfig();

              if (state is RtvOrderLoaded) {
                currentConfig = OrderFilterConfig(
                  destination: state.destination,
                  startDate: state.startDate,
                  endDate: state.endDate,
                  receiverSearch: state.receiverSearch,
                  minCharge: state.minCharge,
                  maxCharge: state.maxCharge,
                );
              } else if (state is RtvOrderLoadingMore) {
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
                    filterType: OrderFilterType.rtv,
                  );

                  if (result != null && context.mounted) {
                    context.read<RtvOrderBloc>().add(
                      RtvOrderFilterChanged(
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
      const RtvOrderListSliver(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
    ];
  }
}
