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
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          title: const Text(
            'Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          actions: [
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeLoadStats()),
            child: const Text('Retry'),
          ),
        ],
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

          _WeeklyPerformanceChart(stats: stats),
          const SizedBox(height: 16),

          _PackagesCard(stats: stats),
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
                          color: AppTheme.successGreen,
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
                          color: AppTheme.rojo,
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
                      color: AppTheme.successGreen,
                      label: 'Success Rate',
                      value: '${successRate.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _ChartLegend(
                      color: AppTheme.rojo,
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

class _WeeklyPerformanceChart extends StatelessWidget {
  final VendorStatsEntity stats;

  const _WeeklyPerformanceChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    // Sample weekly data - in real app, this would come from stats
    final weeklyData = [
      {'day': 'Mon', 'deliveries': 42, 'returns': 5},
      {'day': 'Tue', 'deliveries': 48, 'returns': 4},
      {'day': 'Wed', 'deliveries': 52, 'returns': 6},
      {'day': 'Thu', 'deliveries': 45, 'returns': 3},
      {'day': 'Fri', 'deliveries': 55, 'returns': 7},
      {'day': 'Sat', 'deliveries': 38, 'returns': 4},
      {'day': 'Sun', 'deliveries': 28, 'returns': 2},
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
            'Weekly Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Deliveries vs Returns',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            weeklyData[value.toInt()]['day'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyData.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        (e.value['deliveries'] as int).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.successGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: weeklyData.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        (e.value['returns'] as int).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.rojo,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(
                color: AppTheme.successGreen,
                label: 'Deliveries',
                value: '',
                showDot: true,
              ),
              const SizedBox(width: 20),
              _ChartLegend(
                color: AppTheme.rojo,
                label: 'Returns',
                value: '',
                showDot: true,
              ),
            ],
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
      {'stage': 'Drop Off', 'count': processing.dropOff, 'color': Colors.blue},
      {'stage': 'Pickup', 'count': processing.pickup, 'color': Colors.orange},
      {
        'stage': 'Dispatch',
        'count': processing.dispatch,
        'color': Colors.green,
      },
      if (processing.hold > 0)
        {'stage': 'On Hold', 'count': processing.hold, 'color': Colors.red},
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
  final bool showDot;

  const _ChartLegend({
    required this.color,
    required this.label,
    required this.value,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDot)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          )
        else
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

// ============ Existing Widgets (Unchanged) ============

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
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

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
                Text(
                  greeting,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
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
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
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
                  color: AppTheme.infoBlue,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToDeliveries(context),
                child: _ActivityItem(
                  label: 'Deliveries',
                  value: stats.todayDelivery.toString(),
                  color: AppTheme.successGreen,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToReturns(context),
                child: _ActivityItem(
                  label: 'Returns',
                  value: stats.todaysReturnedDelivery.toString(),
                  color: AppTheme.rojo,
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
