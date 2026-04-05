import 'dart:io';
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
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(const HomeLoadStats()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final isError = state is HomeError;
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              title: const Text(
                'Dashboard',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
              leading: isError
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
              actions: [
                if (!isError)
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {
                      context.router.push(const NoticeListRoute());
                    },
                  ),
              ],
            ),
            body: BlocListener<AuthBloc, AuthState>(
              listener: (context, authState) {
                if (authState is AuthUnauthenticated) {
                  context.router.replace(const LoginRoute());
                }
              },
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return _buildLoadingState();
                  }
                  if (state is HomeError) {
                    return _buildErrorState(context, state.message);
                  }
                  if (state is HomeLoaded) {
                    return _buildLoadedState(context, state.stats);
                  }
                  return const SizedBox();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShimmerCard(height: 120),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 80),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 200),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 150),
      ],
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.read<HomeBloc>().add(const HomeLoadStats()),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => exit(0),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, VendorStatsEntity stats) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshStats());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WelcomeCard(
            vendorName: stats.vendorName,
            onAddTicket: () {
              context.router.push(const CreateTicketRoute());
            },
            onCodRequest: () {
              context.router.push(const PaymentRequestRoute());
            },
            onAddOrder: () {
              context.router.push(const CreateOrderRoute());
            },
          ),
          const SizedBox(height: 16),
          _StatCard(
            title: 'Pending COD',
            value: 'Rs. ${_formatCurrency(stats.pendingCod)}',
            icon: Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),

          _ActivityCard(stats: stats),
          const SizedBox(height: 16),

          _SuccessReturnChart(
            successRate: stats.successPercent,
            returnRate: stats.returnPercent,
          ),
          const SizedBox(height: 16),

          _ProcessingOrdersChart(processing: stats.processingOrders),
          const SizedBox(height: 16),

          _PackagesCard(stats: stats),
          const SizedBox(height: 16),

          _OrdersInProcessCard(stats: stats),
          const SizedBox(height: 16),

          _DeliveryMetricsCard(stats: stats),
          const SizedBox(height: 16),

          _ReturnedPackagesCard(stats: stats),
          const SizedBox(height: 16),

          _OrderStatusCard(stats: stats),
          const SizedBox(height: 16),

          _LastCodCard(stats: stats),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ============ FL Chart Components ============

class _SuccessReturnChart extends StatelessWidget {
  final double successRate;
  final double returnRate;

  const _SuccessReturnChart({
    required this.successRate,
    required this.returnRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Success vs Return Rates',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: AppTheme.marianBlue,
                          value: successRate,
                          radius: 60,
                          title: '${successRate.toStringAsFixed(1)}%',
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppTheme.darkGray,
                          value: returnRate,
                          radius: 60,
                          title: '${returnRate.toStringAsFixed(1)}%',
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.grey.shade300,
                          value: 100 - successRate - returnRate,
                          radius: 60,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChartLegend(
                      color: AppTheme.marianBlue,
                      label: 'Success Rate',
                      value: '${successRate.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _ChartLegend(
                      color: AppTheme.darkGray,
                      label: 'Return Rate',
                      value: '${returnRate.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _ChartLegend(
                      color: Colors.grey.shade300,
                      label: 'Other',
                      value:
                          '${(100 - successRate - returnRate).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _ProcessingOrdersChart extends StatelessWidget {
  final ProcessingOrdersEntity processing;

  const _ProcessingOrdersChart({required this.processing});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'stage': 'Drop Off', 'count': processing.dropOff, 'color': AppTheme.marianBlue},
      {'stage': 'Pickup', 'count': processing.pickup, 'color': AppTheme.marianBlue},
      {
        'stage': 'Dispatch',
        'count': processing.dispatch,
        'color': AppTheme.marianBlue,
      },
      if (processing.hold > 0)
        {'stage': 'On Hold', 'count': processing.hold, 'color': AppTheme.marianBlue},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Processing Stages',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Current order distribution',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(fontSize: 12),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum:
                    data
                        .map((e) => e['count'] as int)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.2,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(fontSize: 12),
              ),
              series: <CartesianSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: data,
                  xValueMapper: (Map<String, dynamic> data, _) =>
                      data['stage'] as String,
                  yValueMapper: (Map<String, dynamic> data, _) =>
                      data['count'] as int,
                  pointColorMapper: (Map<String, dynamic> data, _) =>
                      data['color'] as Color,
                  borderRadius: BorderRadius.circular(4),
                  width: 0.6,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _ChartLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}


class _WelcomeCard extends StatelessWidget {
  final String vendorName;
  final VoidCallback onAddTicket;
  final VoidCallback onCodRequest;
  final VoidCallback onAddOrder;

  const _WelcomeCard({
    required this.vendorName,
    required this.onAddTicket,
    required this.onCodRequest,
    required this.onAddOrder,
  });

  @override
  Widget build(BuildContext context) {
  
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
           
                const SizedBox(height: 4),
                Text(
                  vendorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.blue,
            onPressed: () async {
              final result = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 16, 0),
                items: const [
                  PopupMenuItem(
                    value: 'ticket',
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined),
                        SizedBox(width: 8),
                        Text('Add Tickets'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cod',
                    child: Row(
                      children: [
                        Icon(Icons.payment),
                        SizedBox(width: 8),
                        Text('COD Request'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: '0rder',
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined),
                        SizedBox(width: 8),
                        Text('Add Order'),
                      ],
                    ),
                  ),
                ],
              );

              if (result == 'ticket') {
                onAddTicket();
              }
              if (result == 'cod') {
                onCodRequest();
              }
              if (result == '0rder') {
                onAddOrder();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ActivityCard({required this.stats});

  void _navigateToComments(BuildContext context) {
    context.router.push(CommentsRoute(initialTab: 0));
  }

  void _navigateToDeliveries(BuildContext context) {
    context.router.push(OrdersRoute(initialTab: 1));
  }

  void _navigateToReturns(BuildContext context) {
    context.router.push(OrdersRoute(initialTab: 4));
  }

  void _navigateToOrders(BuildContext context) {
    context.router.push(OrdersRoute(initialTab: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Activity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              GestureDetector(
                onTap: () => _navigateToOrders(context),
                child: _ActivityItem(
                  label: 'Orders Created',
                  value: stats.todayOrderCreated.toString(),
                  color: AppTheme.marianBlue,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToDeliveries(context),
                child: _ActivityItem(
                  label: 'Deliveries',
                  value: stats.todayDelivery.toString(),
                  color: AppTheme.marianBlue,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToReturns(context),
                child: _ActivityItem(
                  label: 'Returns',
                  value: stats.todaysReturnedDelivery.toString(),
                  color: AppTheme.marianBlue,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToComments(context),
                child: _ActivityItem(
                  label: 'Comments',
                  value: stats.todaysComment.toString(),
                  color: AppTheme.marianBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ActivityItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackagesCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _PackagesCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Packages Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.totalPackages.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Packages',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.deliveredPackages.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delivered',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) {
  if (amount >= 10000000) {
    return '${(amount / 10000000).toStringAsFixed(1)}Cr';
  } else if (amount >= 100000) {
    return '${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  }
  return amount.toStringAsFixed(0);
}

class _OrdersInProcessCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _OrdersInProcessCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Orders in Process',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.ordersInProcess.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs. ${_formatCurrency(stats.ordersInProcessVal)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.marianBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Value',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryMetricsCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _DeliveryMetricsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Metrics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _DeliveryMetricItem(
            label: 'In Return Process',
            value: stats.ordersInReturnProcess.toString(),
            color: AppTheme.marianBlue,
          ),
          const SizedBox(height: 12),
          _DeliveryMetricItem(
            label: 'In Delivery Process',
            value: stats.ordersInDeliveryProcess.toString(),
            color: AppTheme.marianBlue,
          ),
          const SizedBox(height: 12),
          _DeliveryMetricItem(
            label: 'Stale Orders',
            value: stats.staleOrders.toString(),
            color: AppTheme.marianBlue,
          ),
          const SizedBox(height: 12),
          _DeliveryMetricItem(
            label: 'Total Delivery Charge',
            value: 'Rs. ${_formatCurrency(stats.totalDelvCharge)}',
            color: AppTheme.marianBlue,
          ),
        ],
      ),
    );
  }
}

class _DeliveryMetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DeliveryMetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ReturnedPackagesCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ReturnedPackagesCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Returned Packages',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.trueReturnedPackages.count.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.marianBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Successfully Returned',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${stats.trueReturnedPackages.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.marianBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.falseReturnedPackages.count.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.marianBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Failed Returns',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${stats.falseReturnedPackages.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.marianBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _OrderStatusCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _StatusItem(
                label: 'Total RTV',
                value: stats.totalRtvOrder.toString(),
                color: AppTheme.marianBlue,
              ),
              _StatusItem(
                label: 'On Hold',
                value: stats.totalHoldOrder.toString(),
                color: AppTheme.marianBlue,
              ),
              _StatusItem(
                label: 'Redirect %',
                value: '${stats.redirectPercentage.toStringAsFixed(1)}%',
                color: AppTheme.marianBlue,
              ),
              _StatusItem(
                label: 'Incoming Returns',
                value: stats.incomingReturns.toString(),
                color: AppTheme.marianBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastCodCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _LastCodCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last COD Transaction',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${_formatCurrency(stats.lastCodAmount)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.marianBlue,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stats.lasstCodDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
