import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/sales_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/sales/sales_report_analysis_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/sales/sales_report_analysis_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/sales/sales_report_analysis_state.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

@RoutePage()
class SalesReportAnalysisScreen extends StatefulWidget {
  const SalesReportAnalysisScreen({super.key});

  @override
  State<SalesReportAnalysisScreen> createState() =>
      _SalesReportAnalysisScreenState();
}

class _SalesReportAnalysisScreenState
    extends State<SalesReportAnalysisScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  static const int maxDaysRange = 180;
  String? _dateRangeError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedStartDate = DateTime(now.year, now.month, 1);
    _selectedEndDate = now;
    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedStartDate!);
    _endDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedEndDate!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAnalysis();
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  bool _validateDateRange(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    if (difference > maxDaysRange) {
      setState(() {
        _dateRangeError =
            'Date range cannot exceed $maxDaysRange days (6 months). Current range: ${difference + 1} days';
      });
      return false;
    } else {
      setState(() {
        _dateRangeError = null;
      });
      return true;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _selectedStartDate : _selectedEndDate;
    final now = DateTime.now();

    late DateTime firstDate;
    late DateTime lastDate;

    if (isStartDate) {
      firstDate = now.subtract(const Duration(days: 365));
      lastDate = _selectedEndDate ?? now;
    } else {
      firstDate = _selectedStartDate ?? now.subtract(const Duration(days: 365));
      lastDate = now;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (isStartDate) {
        if (_selectedEndDate != null) {
          if (!_validateDateRange(pickedDate, _selectedEndDate!)) {
            return;
          }
        }
        _selectedStartDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      } else {
        if (_selectedStartDate != null) {
          if (!_validateDateRange(_selectedStartDate!, pickedDate)) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_dateRangeError ?? 'Invalid date range'),
                backgroundColor: AppTheme.rojo,
              ),
            );
            return;
          }
        }
        _selectedEndDate = pickedDate;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      }
      _fetchAnalysis();
    }
  }

  void _fetchAnalysis() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      if (!_validateDateRange(_selectedStartDate!, _selectedEndDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_dateRangeError ?? 'Invalid date range'),
            backgroundColor: AppTheme.rojo,
          ),
        );
        return;
      }
      context.read<SalesReportAnalysisBloc>().add(
            FetchSalesReportAnalysisEvent(
              startDate: _startDateController.text,
              endDate: _endDateController.text,
            ),
          );
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    _selectedStartDate = DateTime(now.year, now.month, 1);
    _selectedEndDate = now;

    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedStartDate!);
    _endDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedEndDate!);

    setState(() {
      _dateRangeError = null;
    });

    _fetchAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      appBar: AppBar(
        backgroundColor: AppTheme.marianBlue,
        foregroundColor: AppTheme.whiteSmoke,
        title: const Text('Sales Report Analysis'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFilters,
            tooltip: 'Reset to current month',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDateFilterSection(),
            const SizedBox(height: 8),

            BlocBuilder<SalesReportAnalysisBloc, SalesReportAnalysisState>(
              builder: (context, state) {
                if (state is SalesReportAnalysisLoaded) {
                  return _buildStatsCards(state.salesReportAnalysis);
                }
                return const SizedBox.shrink();
              },
            ),

            BlocBuilder<SalesReportAnalysisBloc, SalesReportAnalysisState>(
              builder: (context, state) {
                return _buildContentBasedOnState(state);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: AppTheme.marianBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Select Date Range',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.powerBlue, width: 1),
                ),
                child: Text(
                  'Max: 6 months',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_dateRangeError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.rojo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.rojo.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppTheme.rojo, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dateRangeError!,
                      style: TextStyle(color: AppTheme.rojo, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  controller: _startDateController,
                  label: 'Start Date',
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  controller: _endDateController,
                  label: 'End Date',
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _fetchAnalysis,
            icon: const Icon(Icons.analytics, size: 20),
            label: const Text('Analyze Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.marianBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.powerBlue.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppTheme.marianBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.text,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppTheme.darkGray),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(SalesReportAnalysis analysis) {
    final deliveryRate = analysis.totalOrders > 0
        ? (analysis.totalDeliveredOrders / analysis.totalOrders * 100)
            .toStringAsFixed(1)
        : '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: 'Rs.${analysis.totalSales.toStringAsFixed(2)}',
                  label: 'Total Sales',
                  icon: Icons.attach_money,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: 'Rs.${analysis.totalPackageValue.toStringAsFixed(2)}',
                  label: 'Package Value',
                  icon: Icons.inventory,
                  color: AppTheme.infoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: '${analysis.totalOrders}',
                  label: 'Total Orders',
                  icon: Icons.shopping_cart,
                  color: AppTheme.marianBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: '${analysis.totalDeliveredOrders}',
                  label: 'Delivered',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: '${analysis.totalReturnedOrders}',
                  label: 'Returned',
                  icon: Icons.undo,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            value: '$deliveryRate%',
            label: 'Delivery Rate',
            icon: Icons.trending_up,
            color: Colors.purple,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fullWidth ? 24 : 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBasedOnState(SalesReportAnalysisState state) {
    if (state is SalesReportAnalysisInitial) {
      return _buildInitialView();
    } else if (state is SalesReportAnalysisLoading) {
      return _buildShimmerLoading();
    } else if (state is SalesReportAnalysisLoaded) {
      return _buildAnalysisView(state.salesReportAnalysis);
    } else if (state is SalesReportAnalysisEmpty) {
      return _buildEmptyView();
    } else if (state is SalesReportAnalysisError) {
      return _buildErrorView(state.message);
    }
    return Container();
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: AppTheme.powerBlue.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select dates and click "Analyze Data"',
              style: TextStyle(fontSize: 16, color: AppTheme.darkGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Shimmer for stats cards
          Row(
            children: [
              Expanded(child: _buildShimmerCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard()),
            ],
          ),
          const SizedBox(height: 24),

          // Shimmer for charts
          _buildShimmerChart('Sales Trend'),
          const SizedBox(height: 24),
          _buildShimmerChart('Order Trends'),
          const SizedBox(height: 24),

          // Shimmer for table
          _buildShimmerTable(),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 60,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerChart(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 150,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 200,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: List.generate(
                  6,
                  (colIndex) => Expanded(
                    child: Container(
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisView(SalesReportAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sales Chart Section
        _buildSalesChart(analysis),
        const SizedBox(height: 24),

        // Orders Chart Section
        _buildOrdersChart(analysis),
        const SizedBox(height: 24),

        // Daily Details Section
        _buildDailyDetailsSection(analysis),
      ],
    );
  }

  Widget _buildSalesChart(SalesReportAnalysis analysis) {
    final dailyReports = analysis.dailyReports;
    if (dailyReports.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 20, color: AppTheme.marianBlue),
              const SizedBox(width: 8),
              Text(
                'Daily Sales Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Rs.${analysis.totalSales.toStringAsFixed(2)} total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_startDateController.text} to ${_endDateController.text}',
            style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 11),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Sales (Rs.)',
                  textStyle: const TextStyle(fontSize: 12),
                ),
                majorGridLines: const MajorGridLines(
                  color: Color(0xffeeeeee),
                  width: 1,
                ),
                axisLine: const AxisLine(width: 0),
                numberFormat: NumberFormat.currency(symbol: 'Rs.'),
              ),
              series: <LineSeries<DailySalesReport, String>>[
                LineSeries<DailySalesReport, String>(
                  dataSource: dailyReports,
                  xValueMapper: (data, _) =>
                      DateFormat('MMM dd').format(data.createdDate),
                  yValueMapper: (data, _) => data.sales,
                  name: 'Sales',
                  color: AppTheme.marianBlue,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    shape: DataMarkerType.circle,
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                canShowMarker: true,
                color: Colors.white,
                textStyle: const TextStyle(color: Colors.black, fontSize: 12),
                borderColor: AppTheme.marianBlue,
                borderWidth: 1,
                builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                  final salesPoint = data as DailySalesReport;
                  return Text('Rs.${salesPoint.sales.toStringAsFixed(2)}');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart(SalesReportAnalysis analysis) {
    final dailyReports = analysis.dailyReports;
    if (dailyReports.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_cart, size: 20, color: AppTheme.marianBlue),
              const SizedBox(width: 8),
              Text(
                'Daily Order Trends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${analysis.totalOrders} total orders',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_startDateController.text} to ${_endDateController.text}',
            style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 11),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Number of Orders',
                  textStyle: const TextStyle(fontSize: 12),
                ),
                majorGridLines: const MajorGridLines(
                  color: Color(0xffeeeeee),
                  width: 1,
                ),
                axisLine: const AxisLine(width: 0),
              ),
              series: <ColumnSeries<DailySalesReport, String>>[
                ColumnSeries<DailySalesReport, String>(
                  dataSource: dailyReports,
                  xValueMapper: (data, _) =>
                      DateFormat('MMM dd').format(data.createdDate),
                  yValueMapper: (data, _) => data.totalOrders.toDouble(),
                  name: 'Total Orders',
                  color: AppTheme.marianBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  width: 0.6,
                ),
                ColumnSeries<DailySalesReport, String>(
                  dataSource: dailyReports,
                  xValueMapper: (data, _) =>
                      DateFormat('MMM dd').format(data.createdDate),
                  yValueMapper: (data, _) => data.deliveredOrders.toDouble(),
                  name: 'Delivered',
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  width: 0.6,
                ),
              ],
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                canShowMarker: false,
                color: Colors.white,
                textStyle: const TextStyle(color: Colors.black, fontSize: 12),
                borderColor: AppTheme.marianBlue,
                borderWidth: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyDetailsSection(SalesReportAnalysis analysis) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, size: 20, color: AppTheme.marianBlue),
              const SizedBox(width: 8),
              Text(
                'Daily Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${analysis.dailyReports.length} days',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.dailyReports.map((daily) {
            return _buildDailyItem(daily);
          }),
        ],
      ),
    );
  }

  Widget _buildDailyItem(DailySalesReport daily) {
    final deliveryRate = daily.totalOrders > 0
        ? (daily.deliveredOrders / daily.totalOrders * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTheme.powerBlue.withValues(alpha: 0.1)),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.marianBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              size: 20,
              color: AppTheme.marianBlue,
            ),
          ),
          title: Text(
            DateFormat('MMM dd, yyyy').format(daily.createdDate),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Rs.${daily.sales.toStringAsFixed(2)} sales',
            style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: daily.sales > 0
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: daily.sales > 0
                    ? AppTheme.successGreen.withValues(alpha: 0.3)
                    : AppTheme.darkGray.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              'Rs.${daily.sales.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: daily.sales > 0 ? AppTheme.successGreen : AppTheme.darkGray,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildDailyStatRow(
                    'Total Orders',
                    '${daily.totalOrders}',
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildDailyStatRow(
                    'Delivered',
                    '${daily.deliveredOrders}',
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildDailyStatRow(
                    'Returned',
                    '${daily.returnedOrders}',
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildDailyStatRow(
                    'Package Value',
                    'Rs.${daily.packageValue.toStringAsFixed(2)}',
                    Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  _buildDailyStatRow(
                    'Delivery Rate',
                    '$deliveryRate%',
                    AppTheme.successGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStatRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.darkGray,
            ),
          ),
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

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 80,
              color: AppTheme.powerBlue.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Sales Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No sales data found for the selected date range',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset to Current Month'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppTheme.rojo),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.rojo,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}