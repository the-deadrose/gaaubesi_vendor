import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/app/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/app/auth/presentation/bloc/auth_state.dart';
import 'package:gaaubesi_vendor/app/home/domain/entities/vendor_stats_entity.dart';
import 'package:gaaubesi_vendor/app/home/presentation/bloc/home_bloc.dart';
import 'package:gaaubesi_vendor/app/home/presentation/bloc/home_event.dart';
import 'package:gaaubesi_vendor/app/home/presentation/bloc/home_state.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(const HomeLoadStats()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          String vendorName = 'Home';
          if (state is HomeLoaded) {
            vendorName = state.stats.vendorName;
          }
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
                onPressed: () {
                  final scaffoldState = Scaffold.of(context);
                  if (scaffoldState.hasDrawer) {
                    scaffoldState.openDrawer();
                  }
                },
              ),
              title: Text(
                vendorName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: theme.colorScheme.primary,
              elevation: 0,
            ),
            body: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  context.router.replace(const LoginRoute());
                }
              },
              child: _HomeBody(state: state),
            ),
          );
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final HomeState state;

  const _HomeBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (state is HomeLoading) {
          return const _LoadingShimmer();
        } else if (state is HomeError) {
          return _ErrorView(message: (state as HomeError).message);
        } else if (state is HomeLoaded) {
          return _HomeContent(stats: (state as HomeLoaded).stats);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final VendorStatsEntity stats;

  const _HomeContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshStats());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _FinancialSection(stats: stats),
          const SliverToBoxAdapter(child: SizedBox(height: 5)),

          _KeyMetricsSection(stats: stats),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          _TodaysActivitySection(stats: stats),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          _ProcessingStatusSection(stats: stats),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          _PackageOverviewSection(stats: stats),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          _OrderStatusSection(stats: stats),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          _ReturnsAnalysisSection(stats: stats),
          const SliverToBoxAdapter(child: SizedBox(height: 56)),
        ],
      ),
    );
  }
}

// Section Widgets

class _FinancialSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _FinancialSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        bool showAmounts = true;
        if (state is HomeLoaded) {
          showAmounts = state.showAmounts;
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),
              _FinancialCard(
                stats: stats,
                showAmounts: showAmounts,
                onToggleVisibility: () {
                  context.read<HomeBloc>().add(const HomeToggleAmountVisibility());
                },
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _KeyMetricsSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _KeyMetricsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final statusColors = AppTheme.statusColors;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _MetricCard(
                    title: 'Success Rate',
                    value: '${stats.successPercent.toStringAsFixed(1)}%',
                    icon: Icons.trending_up_sharp,
                    color: statusColors['success']!,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _MetricCard(
                    title: 'Return Rate',
                    value: '${stats.returnPercent.toStringAsFixed(1)}%',
                    icon: Icons.trending_down,
                    color: statusColors['warning']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaysActivitySection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _TodaysActivitySection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const _SectionTitle(title: "Today's Activity"),
          const SizedBox(height: 12),
          _TodaysActivityGrid(stats: stats),
        ]),
      ),
    );
  }
}

class _ProcessingStatusSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ProcessingStatusSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const _SectionTitle(title: 'Processing Status'),
          const SizedBox(height: 12),
          _ProcessingBreakdown(stats: stats),
        ]),
      ),
    );
  }
}

class _PackageOverviewSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _PackageOverviewSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const _SectionTitle(title: 'Package Overview'),
          const SizedBox(height: 12),
          _PackageOverviewGrid(stats: stats),
        ]),
      ),
    );
  }
}

class _OrderStatusSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _OrderStatusSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const _SectionTitle(title: 'Order Status'),
          const SizedBox(height: 12),
          _OrderStatusGrid(stats: stats),
        ]),
      ),
    );
  }
}

class _ReturnsAnalysisSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ReturnsAnalysisSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const _SectionTitle(title: 'Returns Analysis'),
          const SizedBox(height: 12),
          _ReturnsAnalysisGrid(stats: stats),
        ]),
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final VendorStatsEntity stats;
  final bool showAmounts;
  final VoidCallback onToggleVisibility;

  const _FinancialCard({
    required this.stats,
    required this.showAmounts,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppTheme.financialbox),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending COD',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      showAmounts
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  Icon(
                    Icons.account_balance_wallet,
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            showAmounts
                ? 'Rs. ${stats.pendingCod.toStringAsFixed(2)}'
                : 'Rs. *****',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _FinancialDetailItem(
                  label: 'Last COD',
                  value: showAmounts
                      ? 'Rs. ${stats.lastCodAmount.toStringAsFixed(2)}'
                      : 'Rs. *****',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _FinancialDetailItem(
                    label: 'In Process',
                    value: showAmounts
                        ? 'Rs. ${stats.ordersInProcessVal.toStringAsFixed(2)}'
                        : 'Rs. *****',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MiniStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReturnStatItem extends StatelessWidget {
  final String label;
  final int count;
  final double value;
  final Color color;

  const _ReturnStatItem({
    required this.label,
    required this.count,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Count', style: theme.textTheme.bodySmall),
              Text(
                count.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Value', style: theme.textTheme.bodySmall),
              Text(
                'Rs. ${value.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================
// Grid Widgets
// ============================

class _TodaysActivityGrid extends StatelessWidget {
  final VendorStatsEntity stats;

  const _TodaysActivityGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = AppTheme.statusColors;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      children: [
        _StatItem(
          label: 'Orders Created',
          value: stats.todayOrderCreated.toString(),
          icon: Icons.add_shopping_cart,
          color: statusColors['info']!,
        ),
        _StatItem(
          label: 'Deliveries',
          value: stats.todayDelivery.toString(),
          icon: Icons.local_shipping,
          color: statusColors['success']!,
        ),
        _StatItem(
          label: 'Returns',
          value: stats.todaysReturnedDelivery.toString(),
          icon: Icons.assignment_return,
          color: theme.colorScheme.error,
        ),
        _StatItem(
          label: 'Comments',
          value: stats.todaysComment.toString(),
          icon: Icons.comment,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _PackageOverviewGrid extends StatelessWidget {
  final VendorStatsEntity stats;

  const _PackageOverviewGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColors = AppTheme.statusColors;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      children: [
        _StatItem(
          label: 'Total Packages',
          value: stats.totalPackages.toString(),
          icon: Icons.inventory,
          color: colorScheme.primary,
        ),
        _StatItem(
          label: 'Delivered',
          value: stats.deliveredPackages.toString(),
          icon: Icons.check_circle,
          color: statusColors['success']!,
        ),
        _StatItem(
          label: 'Total Value',
          value: 'Rs. ${stats.totalPackagesValue.toStringAsFixed(2)}',
          icon: Icons.monetization_on,
          color: statusColors['success']!,
        ),
        _StatItem(
          label: 'Delivered Value',
          value: 'Rs. ${stats.deliveredPackagesValue.toStringAsFixed(2)}',
          icon: Icons.price_check,
          color: statusColors['success']!,
        ),
      ],
    );
  }
}

class _OrderStatusGrid extends StatelessWidget {
  final VendorStatsEntity stats;

  const _OrderStatusGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColors = AppTheme.statusColors;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      children: [
        _MiniStatItem(
          label: 'In Process',
          value: stats.ordersInProcess.toString(),
          color: colorScheme.primary,
        ),
        _MiniStatItem(
          label: 'In Delivery',
          value: stats.ordersInDeliveryProcess.toString(),
          color: colorScheme.secondary,
        ),
        _MiniStatItem(
          label: 'In Return',
          value: stats.ordersInReturnProcess.toString(),
          color: statusColors['warning']!,
        ),
        _MiniStatItem(
          label: 'Incoming',
          value: stats.incomingReturns.toString(),
          color: colorScheme.error,
        ),
        _MiniStatItem(
          label: 'Hold',
          value: stats.totalHoldOrder.toString(),
          color: statusColors['warning']!,
        ),
        _MiniStatItem(
          label: 'RTV',
          value: stats.totalRtvOrder.toString(),
          color: colorScheme.tertiary,
        ),
      ],
    );
  }
}

class _ReturnsAnalysisGrid extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ReturnsAnalysisGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      children: [
        _ReturnStatItem(
          label: 'True Returns',
          count: stats.trueReturnedPackages.count,
          value: stats.trueReturnedPackages.value,
          color: colorScheme.error,
        ),
        _ReturnStatItem(
          label: 'False Returns',
          count: stats.falseReturnedPackages.count,
          value: stats.falseReturnedPackages.value,
          color: colorScheme.tertiary,
        ),
      ],
    );
  }
}

// ============================
// Processing Breakdown Widget
// ============================

class _ProcessingBreakdown extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ProcessingBreakdown({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColors = AppTheme.statusColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProcessingItem(
            label: 'Drop Off',
            count: stats.processingOrders.dropOff,
            color: colorScheme.primary,
            icon: Icons.inventory_2_outlined,
          ),
          Divider(height: 24, color: colorScheme.outline),
          _ProcessingItem(
            label: 'Pickup',
            count: stats.processingOrders.pickup,
            color: colorScheme.secondary,
            icon: Icons.local_shipping_outlined,
          ),
          Divider(height: 24, color: colorScheme.outline),
          _ProcessingItem(
            label: 'Sent Pickup',
            count: stats.processingOrders.sentPickup,
            color: statusColors['warning']!,
            icon: Icons.send_outlined,
          ),
          Divider(height: 24, color: colorScheme.outline),
          _ProcessingItem(
            label: 'Pickup Complete',
            count: stats.processingOrders.pickupComplete,
            color: statusColors['success']!,
            icon: Icons.check_circle_outline,
          ),
          Divider(height: 24, color: colorScheme.outline),
          _ProcessingItem(
            label: 'Dispatch',
            count: stats.processingOrders.dispatch,
            color: colorScheme.tertiary,
            icon: Icons.directions_car_outlined,
          ),
        ],
      ),
    );
  }
}

class _ProcessingItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _ProcessingItem({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ============================
// Helper Widgets
// ============================

class _FinancialDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _FinancialDetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading stats',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeLoadStats());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================
// Shimmer Loading Widget
// ============================

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return CustomScrollView(
      slivers: [
        // Financial Section Shimmer
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),
              const _ShimmerCard(
                height: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerRow(width: 120, height: 20),
                    SizedBox(height: 8),
                    _ShimmerRow(width: 80, height: 16),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        _ShimmerBox(width: 60, height: 40),
                        SizedBox(width: 16),
                        _ShimmerBox(width: 60, height: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
        ),
        ),
    
        // Key Metrics Section Shimmer
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 12),
                Row(
                  children: [
                    _ShimmerCard(width: 160, height: 80),
                    SizedBox(width: 16),
                    _ShimmerCard(height: 80),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Today's Activity Section Shimmer
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _ShimmerCard(height: 40, child: _ShimmerGrid(crossAxisCount: 2)),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Processing Status Section Shimmer
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _ShimmerCard(height: 200, child: _ShimmerList(itemCount: 5)),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Package Overview Section Shimmer
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _ShimmerCard(height: 120, child: _ShimmerGrid(crossAxisCount: 2)),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Order Status Section Shimmer
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _ShimmerCard(height: 100, child: _ShimmerGrid(crossAxisCount: 3)),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Returns Analysis Section Shimmer
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _ShimmerCard(height: 80, child: _ShimmerGrid(crossAxisCount: 2)),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 56)),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const _ShimmerCard({this.width, this.height, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      padding: child != null ? const EdgeInsets.all(8) : const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface.withValues(alpha: 0.3),
            colorScheme.surface.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child ?? const SizedBox(),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerRow({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surface.withValues(alpha: 0.3),
      ),
      child: Stack(
        children: [
          // Shimmer effect
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface.withValues(alpha: 0.0),
                    colorScheme.surface.withValues(alpha: 0.2),
                    colorScheme.surface.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: const Alignment(-1.0, 0.0),
                  end: const Alignment(1.0, 0.0),
                  transform: const GradientRotation(0.785398163), // 45 degrees
                ),
              ),
            ),
          ),
          // Base color
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.surface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface.withValues(alpha: 0.3),
      ),
      child: Stack(
        children: [
          // Shimmer effect
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface.withValues(alpha: 0.0),
                    colorScheme.surface.withValues(alpha: 0.2),
                    colorScheme.surface.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: const Alignment(-1.0, 0.0),
                  end: const Alignment(1.0, 0.0),
                  transform: const GradientRotation(0.785398163), // 45 degrees
                ),
              ),
            ),
          ),
          // Base color
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  final int crossAxisCount;

  const _ShimmerGrid({required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      children: List.generate(
        crossAxisCount * 2, // 2 rows
        (index) => const _ShimmerBox(width: 60, height: 50),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  final int itemCount;

  const _ShimmerList({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: _ShimmerRow(width: double.infinity, height: 20),
        ),
      ),
    );
  }
}


