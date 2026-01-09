import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaaubesi_vendor/features/home/domain/entities/vendor_stats_entity.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_bloc.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_event.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_state.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(const HomeLoadStats()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          String vendorName = 'Home';
          if (state is HomeLoaded) {
            vendorName = state.stats.vendorName;
          }
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  final scaffoldState = Scaffold.of(context);
                  if (scaffoldState.hasDrawer) {
                    scaffoldState.openDrawer();
                  }
                },
              ),
              title: Text(
                vendorName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
            ),
            body: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  context.router.replace(const LoginRoute());
                }
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (authContext, authState) {
                  // If user is being logged out, show loading instead of error
                  if (authState is AuthUnauthenticated || authState is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return Builder(
                    builder: (context) {
                      if (state is HomeLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is HomeError) {
                        return _ErrorView(message: state.message);
                      } else if (state is HomeLoaded) {
                        return _HomeContent(stats: state.stats);
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final VendorStatsEntity stats;

  const _HomeContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshStats());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FinancialCard(stats: stats),
            const SizedBox(height: 24),
            _SimplifiedMetricsSection(stats: stats),
            const SizedBox(height: 24),
            _SimplifiedActivitySection(stats: stats),
            const SizedBox(height: 24),
            _SimplifiedProcessingSection(stats: stats),
            const SizedBox(height: 24),
            _SimplifiedPackagesSection(stats: stats),
            const SizedBox(height: 24),
            _SimplifiedOrderStatusSection(stats: stats),
            const SizedBox(height: 24),
            _SimplifiedReturnsSection(stats: stats),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SimplifiedMetricsSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _SimplifiedMetricsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SimplifiedMetricItem(
                  title: 'Success Rate',
                  value: '${stats.successPercent.toStringAsFixed(1)}%',
                  color: AppTheme.successGreen,
                ),
              ),
              Expanded(
                child: _SimplifiedMetricItem(
                  title: 'Return Rate',
                  value: '${stats.returnPercent.toStringAsFixed(1)}%',
                  color: AppTheme.warningYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimplifiedMetricItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SimplifiedMetricItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _FinancialCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F38), Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1F38).withValues(alpha: 0.3),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const Icon(Icons.account_balance_wallet, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rs. ${_formatCurrency(stats.pendingCod)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _FinancialDetailItem(
                  label: 'Last COD',
                  value: 'Rs. ${_formatCurrency(stats.lastCodAmount)}',
                  date: stats.lasstCodDate.isNotEmpty
                      ? stats.lasstCodDate
                      : null,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _FinancialDetailItem(
                    label: 'In Process',
                    value: 'Rs. ${_formatCurrency(stats.ordersInProcessVal)}',
                    count: stats.ordersInProcess,
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

class _FinancialDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final String? date;
  final int? count;

  const _FinancialDetailItem({
    required this.label,
    required this.value,
    this.date,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (date != null) ...[
          const SizedBox(height: 4),
          Text(
            date!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
        if (count != null) ...[
          const SizedBox(height: 4),
          Text(
            '$count orders',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ],
    );
  }
}

class _SimplifiedActivitySection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _SimplifiedActivitySection({required this.stats});

  void _navigateToComments(BuildContext context) {
    context.router.push(CommentsRoute(initialTab: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Activity",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SimplifiedActivityItem(
                  label: 'Orders Created',
                  value: stats.todayOrderCreated.toString(),
                  color: AppTheme.infoBlue,
                ),
              ),
              Expanded(
                child: _SimplifiedActivityItem(
                  label: 'Deliveries',
                  value: stats.todayDelivery.toString(),
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SimplifiedActivityItem(
                  label: 'Returns',
                  value: stats.todaysReturnedDelivery.toString(),
                  color: AppTheme.rojo,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToComments(context),
                  child: _SimplifiedActivityItem(
                    label: "Today's Comments",
                    value: stats.todaysComment.toString(),
                    color: AppTheme.marianBlue,
                    isInteractive: true,
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

class _SimplifiedProcessingSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _SimplifiedProcessingSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final processing = stats.processingOrders;
    final totalProcessing =
        processing.dropOff +
        processing.pickup +
        processing.sentPickup +
        processing.dispatch +
        processing.arrived;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Processing Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.marianBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalProcessing total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.marianBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SimplifiedProcessingRow(
            label: 'Drop Off',
            count: processing.dropOff,
            color: AppTheme.infoBlue,
          ),
          _SimplifiedProcessingRow(
            label: 'Pickup',
            count: processing.pickup,
            color: AppTheme.marianBlue,
          ),
          _SimplifiedProcessingRow(
            label: 'Dispatch',
            count: processing.dispatch,
            color: AppTheme.warningYellow,
          ),
          if (processing.hold > 0)
            _SimplifiedProcessingRow(
              label: 'On Hold',
              count: processing.hold,
              color: AppTheme.rojo,
            ),
        ],
      ),
    );
  }
}

class _SimplifiedProcessingRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SimplifiedProcessingRow({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimplifiedPackagesSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _SimplifiedPackagesSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SimplifiedPackageItem(
                  label: 'Total Packages',
                  value: stats.totalPackages.toString(),
                  color: AppTheme.marianBlue,
                ),
              ),
              Expanded(
                child: _SimplifiedPackageItem(
                  label: 'Delivered',
                  value: stats.deliveredPackages.toString(),
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SimplifiedPackageItem(
                  label: 'Total Value',
                  value: 'Rs. ${_formatCurrency(stats.totalPackagesValue)}',
                  color: AppTheme.successGreen,
                ),
              ),
              Expanded(
                child: _SimplifiedPackageItem(
                  label: 'Delivered Value',
                  value: 'Rs. ${_formatCurrency(stats.deliveredPackagesValue)}',
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimplifiedOrderStatusSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _SimplifiedOrderStatusSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SimplifiedStatusItem(
                  label: 'In Process',
                  value: stats.ordersInProcess.toString(),
                  color: AppTheme.infoBlue,
                ),
              ),
              Expanded(
                child: _SimplifiedStatusItem(
                  label: 'In Delivery',
                  value: stats.ordersInDeliveryProcess.toString(),
                  color: AppTheme.marianBlue,
                ),
              ),
              Expanded(
                child: _SimplifiedStatusItem(
                  label: 'In Return',
                  value: stats.ordersInReturnProcess.toString(),
                  color: AppTheme.warningYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SimplifiedStatusItem(
                  label: 'Incoming',
                  value: stats.incomingReturns.toString(),
                  color: AppTheme.rojo,
                ),
              ),
              Expanded(
                child: _SimplifiedStatusItem(
                  label: 'Hold',
                  value: stats.totalHoldOrder.toString(),
                  color: AppTheme.warningYellow,
                ),
              ),
              Expanded(
                child: _SimplifiedStatusItem(
                  label: 'RTV',
                  value: stats.totalRtvOrder.toString(),
                  color: AppTheme.rojo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimplifiedReturnsSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _SimplifiedReturnsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Returns Analysis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SimplifiedReturnItem(
                  label: 'True Returns',
                  count: stats.trueReturnedPackages.count,
                  value: stats.trueReturnedPackages.value,
                  color: AppTheme.rojo,
                ),
              ),
              Expanded(
                child: _SimplifiedReturnItem(
                  label: 'False Returns',
                  count: stats.falseReturnedPackages.count,
                  value: stats.falseReturnedPackages.value,
                  color: AppTheme.warningYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimplifiedActivityItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isInteractive;

  const _SimplifiedActivityItem({
    required this.label,
    required this.value,
    required this.color,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            decoration: isInteractive ? TextDecoration.underline : null,
            decorationColor: isInteractive ? color.withValues(alpha: 0.5) : null,
          ),
        ),
      ],
    );
  }
}

class _SimplifiedStatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SimplifiedStatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SimplifiedReturnItem extends StatelessWidget {
  final String label;
  final int count;
  final double value;
  final Color color;

  const _SimplifiedReturnItem({
    required this.label,
    required this.count,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Value',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              _formatCurrency(value),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SimplifiedPackageItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SimplifiedPackageItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

String _formatCurrency(double amount) {
  if (amount >= 100000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  }
  return amount.toStringAsFixed(0);
}
