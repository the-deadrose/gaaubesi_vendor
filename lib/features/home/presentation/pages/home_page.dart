import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
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
            backgroundColor: const Color(0xFFF5F7FA), // Light grey background
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
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0,
            ),
            body: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  context.router.replace(const LoginRoute());
                }
              },
              child: Builder(
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
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            sliver: _KeyMetricsSection(stats: stats),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'Financial Overview'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(child: _FinancialCard(stats: stats)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: "Today's Activity"),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _TodaysActivityGrid(stats: stats),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'Processing Status'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: _ProcessingBreakdown(stats: stats),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'Package Overview'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _PackageOverviewGrid(stats: stats),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'Order Status'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _OrderStatusGrid(stats: stats),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'Returns Analysis'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _ReturnsAnalysisGrid(stats: stats),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 56)),
        ],
      ),
    );
  }
}



class _KeyMetricsSection extends StatelessWidget {
  final VendorStatsEntity stats;

  const _KeyMetricsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          Expanded(
            child: _MetricCard(
              title: 'Success Rate',
              value: '${stats.successPercent.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: Colors.green,
              isPercent: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _MetricCard(
              title: 'Return Rate',
              value: '${stats.returnPercent.toStringAsFixed(1)}%',
              icon: Icons.trending_down,
              color: Colors.orange,
              isPercent: true,
            ),
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
  final bool isPercent;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
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
            color: const Color(0xFF1A1F38).withOpacity(0.3),
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
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _FinancialDetailItem(
                    label: 'In Process',
                    value: 'Rs. ${_formatCurrency(stats.ordersInProcessVal)}',
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

  const _FinancialDetailItem({required this.label, required this.value});

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
      ],
    );
  }
}

class _TodaysActivityGrid extends StatelessWidget {
  final VendorStatsEntity stats;

  const _TodaysActivityGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatItem(
          label: 'Orders Created',
          value: stats.todayOrderCreated.toString(),
          icon: Icons.add_shopping_cart,
          color: Colors.blue,
        ),
        _StatItem(
          label: 'Deliveries',
          value: stats.todayDelivery.toString(),
          icon: Icons.local_shipping,
          color: Colors.green,
        ),
        _StatItem(
          label: 'Returns',
          value: stats.todaysReturnedDelivery.toString(),
          icon: Icons.assignment_return,
          color: Colors.red,
        ),
        _StatItem(
          label: 'Comments',
          value: stats.todaysComment.toString(),
          icon: Icons.comment,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _ProcessingBreakdown extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ProcessingBreakdown({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProcessingItem(
            label: 'Packed',
            count: stats.processingOrders.packed,
            color: Colors.blue,
            icon: Icons.inventory_2_outlined,
          ),
          const Divider(height: 24),
          _ProcessingItem(
            label: 'Shipped',
            count: stats.processingOrders.shipped,
            color: Colors.indigo,
            icon: Icons.local_shipping_outlined,
          ),
          const Divider(height: 24),
          _ProcessingItem(
            label: 'QC Pending',
            count: stats.processingOrders.qcPending,
            color: Colors.orange,
            icon: Icons.fact_check_outlined,
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
    return SliverGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatItem(
          label: 'Total Packages',
          value: stats.totalPackages.toString(),
          icon: Icons.inventory,
          color: Colors.indigo,
        ),
        _StatItem(
          label: 'Delivered',
          value: stats.deliveredPackages.toString(),
          icon: Icons.check_circle,
          color: Colors.teal,
        ),
        _StatItem(
          label: 'Total Value',
          value: 'Rs. ${_formatCurrency(stats.totalPackagesValue)}',
          icon: Icons.monetization_on,
          color: Colors.green,
        ),
        _StatItem(
          label: 'Delivered Value',
          value: 'Rs. ${_formatCurrency(stats.deliveredPackagesValue)}',
          icon: Icons.price_check,
          color: Colors.teal,
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
    return SliverGrid.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _MiniStatItem(
          label: 'In Process',
          value: stats.ordersInProcess.toString(),
          color: Colors.blue,
        ),
        _MiniStatItem(
          label: 'In Delivery',
          value: stats.ordersInDeliveryProcess.toString(),
          color: Colors.indigo,
        ),
        _MiniStatItem(
          label: 'In Return',
          value: stats.ordersInReturnProcess.toString(),
          color: Colors.orange,
        ),
        _MiniStatItem(
          label: 'Incoming',
          value: stats.incomingReturns.toString(),
          color: Colors.red,
        ),
        _MiniStatItem(
          label: 'Hold',
          value: stats.totalHoldOrder.toString(),
          color: Colors.amber,
        ),
        _MiniStatItem(
          label: 'RTV',
          value: stats.totalRtvOrder.toString(),
          color: Colors.deepOrange,
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
    return SliverGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _ReturnStatItem(
          label: 'True Returns',
          count: stats.trueReturnedPackages.count,
          value: stats.trueReturnedPackages.value,
          color: Colors.red,
        ),
        _ReturnStatItem(
          label: 'False Returns',
          count: stats.falseReturnedPackages.count,
          value: stats.falseReturnedPackages.value,
          color: Colors.orange,
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Count', style: Theme.of(context).textTheme.bodySmall),
              Text(
                count.toString(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Value', style: Theme.of(context).textTheme.bodySmall),
              Text(
                _formatCurrency(value),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
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
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
