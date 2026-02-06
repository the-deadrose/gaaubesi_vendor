import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/pickup_order_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/pickup/pickup_order_analysis_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/pickup/pickup_order_analysis_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/pickup/pickup_order_analysis_state.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

@RoutePage()
class PickupOrderAnalysisScreen extends StatefulWidget {
  const PickupOrderAnalysisScreen({super.key});

  @override
  State<PickupOrderAnalysisScreen> createState() =>
      _PickupOrderAnalysisScreenState();
}

class _PickupOrderAnalysisScreenState extends State<PickupOrderAnalysisScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  static const int maxDaysRange = 30;
  String? _dateRangeError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedEndDate = now;
    _selectedStartDate = now.subtract(const Duration(days: 7));
    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedStartDate!);
    _endDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedEndDate!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PickupOrderAnalysisBloc>().add(
        FetchPickupOrderAnalysisEvent(
          startDate: _startDateController.text,
          endDate: _endDateController.text,
        ),
      );
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
            'Date range cannot exceed $maxDaysRange days. Current range: ${difference + 1} days';
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
      context.read<PickupOrderAnalysisBloc>().add(
        FetchPickupOrderAnalysisEvent(
          startDate: _startDateController.text,
          endDate: _endDateController.text,
        ),
      );
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    _selectedStartDate = now.subtract(const Duration(days: 7));
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
        title: const Text('Pickup Order Analysis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDateFilterSection(),
            const SizedBox(height: 8),

            BlocBuilder<PickupOrderAnalysisBloc, PickupOrderAnalysisState>(
              builder: (context, state) {
                if (state is PickupOrderAnalysisLoaded) {
                  return _buildStatsCards(state.analysis);
                } else if (state is PickupOrderAnalysisFiltered) {
                  return _buildStatsCards(state.analysis);
                }
                return const SizedBox.shrink();
              },
            ),

            BlocBuilder<PickupOrderAnalysisBloc, PickupOrderAnalysisState>(
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
                  'Max: $maxDaysRange days',
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

  Widget _buildStatsCards(PickupOrderAnalysisEntity analysis) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              value: analysis.totalOrders.toString(),
              label: 'Total Orders',
              icon: Icons.shopping_bag,
              color: AppTheme.infoBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: analysis.dailyCounts.length.toString(),
              label: 'Active Days',
              icon: Icons.calendar_month,
              color: AppTheme.successGreen,
            ),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
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

  Widget _buildContentBasedOnState(PickupOrderAnalysisState state) {
    if (state is PickupOrderAnalysisInitial) {
      return _buildInitialView();
    } else if (state is PickupOrderAnalysisLoading) {
      return _buildShimmerLoading();
    } else if (state is PickupOrderAnalysisIsFiltering) {
      return _buildFilteringView();
    } else if (state is PickupOrderAnalysisLoaded) {
      return _buildAnalysisView(state.analysis);
    } else if (state is PickupOrderAnalysisFiltered) {
      return _buildAnalysisView(state.analysis);
    } else if (state is PickupOrderAnalysisEmpty) {
      return _buildEmptyView();
    } else if (state is PickupOrderAnalysisError) {
      return _buildErrorView(state.message);
    }
    return Container();
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: AppTheme.powerBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select dates and click "Analyze Data"',
            style: TextStyle(fontSize: 16, color: AppTheme.darkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 150,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteringView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.marianBlue),
          const SizedBox(height: 16),
          Text(
            'Analyzing data...',
            style: TextStyle(fontSize: 16, color: AppTheme.blackBean),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisView(PickupOrderAnalysisEntity analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailyChart(analysis),
        const SizedBox(height: 24),

        _buildDailyDetailsSection(analysis),
      ],
    );
  }

  Widget _buildDailyChart(PickupOrderAnalysisEntity analysis) {
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
              const Icon(Icons.bar_chart, size: 20, color: AppTheme.marianBlue),
              const SizedBox(width: 8),
              Text(
                'Daily Order Trends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${analysis.fromDate} to ${analysis.toDate}',
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
              series: <ColumnSeries<DailyOrderCountEntity, String>>[
                ColumnSeries<DailyOrderCountEntity, String>(
                  dataSource: analysis.dailyCounts,
                  xValueMapper: (data, _) => data.date,
                  yValueMapper: (data, _) => data.count,
                  name: 'Orders',
                  color: AppTheme.marianBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  width: 0.6,
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x\npoint.y orders',
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

  Widget _buildDailyDetailsSection(PickupOrderAnalysisEntity analysis) {
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
                  '${analysis.dailyCounts.length} days',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.dailyCounts.map((daily) {
            return _buildDailyItem(daily);
          }),
        ],
      ),
    );
  }

  Widget _buildDailyItem(DailyOrderCountEntity daily) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTheme.powerBlue.withValues(alpha: 0.1)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
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
            daily.date,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${daily.count} orders',
            style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: daily.count > 0
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: daily.count > 0
                    ? AppTheme.successGreen.withValues(alpha: 0.3)
                    : AppTheme.darkGray.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${daily.count}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: daily.count > 0
                    ? AppTheme.successGreen
                    : AppTheme.darkGray,
              ),
            ),
          ),
          onTap: () => _showOrderIdsDialog(daily.date, daily.orderIds),
        ),
      ),
    );
  }

  void _showOrderIdsDialog(String date, List<String> orderIds) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        color: AppTheme.marianBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Orders on $date',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${orderIds.length} orders',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: orderIds.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: AppTheme.powerBlue.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.marianBlue.withValues(
                                  alpha: 0.1,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppTheme.marianBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Order #${orderIds[index]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppTheme.darkGray,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.marianBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppTheme.powerBlue.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No pickup orders found for the selected date range',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset to Last 7 Days'),
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
        padding: const EdgeInsets.all(16),
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
