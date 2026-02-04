import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            if (mounted) {}
            return;
          }
        }
        _selectedStartDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      } else {
        if (_selectedStartDate != null) {
          if (!_validateDateRange(_selectedStartDate!, pickedDate)) {
            if (mounted) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_dateRangeError ?? 'Invalid date range'),
                  backgroundColor: Colors.red,
                ),
              );
            }
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
            backgroundColor: Colors.red,
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

    context.read<PickupOrderAnalysisBloc>().add(
      ResetPickupOrderAnalysisEvent(),
    );
    _fetchAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Order Analysis'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to last 7 days',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateFilterSection(),
          const SizedBox(height: 8),

          Expanded(
            child:
                BlocBuilder<PickupOrderAnalysisBloc, PickupOrderAnalysisState>(
                  builder: (context, state) {
                    return _buildContentBasedOnState(state);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Date Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Maximum range: $maxDaysRange days',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (_dateRangeError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dateRangeError!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'From Date',
                      suffixIcon: IconButton(
                        onPressed: () => _selectDate(context, true),
                        icon: const Icon(Icons.calendar_today),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'To Date',
                      suffixIcon: IconButton(
                        onPressed: () => _selectDate(context, false),
                        icon: const Icon(Icons.calendar_today),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchAnalysis,
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBasedOnState(PickupOrderAnalysisState state) {
    if (state is PickupOrderAnalysisInitial) {
      return _buildInitialView();
    } else if (state is PickupOrderAnalysisLoading) {
      return _buildLoadingView();
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Select dates and click Analyze',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildFilteringView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Filtering data...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildAnalysisView(PickupOrderAnalysisEntity analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(analysis),
          const SizedBox(height: 24),
          _buildDailyChart(analysis),
          const SizedBox(height: 24),
          _buildDailyDetails(analysis),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(PickupOrderAnalysisEntity analysis) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    analysis.totalOrders.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Total Orders',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    analysis.dailyCounts.length.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Days with Orders',
                    style: TextStyle(fontSize: 14, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChart(PickupOrderAnalysisEntity analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Order Count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${analysis.fromDate} to ${analysis.toDate}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(labelRotation: -45),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Number of Orders'),
                ),
                series: <ColumnSeries<DailyOrderCountEntity, String>>[
                  ColumnSeries<DailyOrderCountEntity, String>(
                    dataSource: analysis.dailyCounts,
                    xValueMapper: (data, _) => data.date,
                    yValueMapper: (data, _) => data.count,
                    name: 'Orders',
                    color: Colors.blue,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y orders',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyDetails(PickupOrderAnalysisEntity analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Order Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...analysis.dailyCounts.map((daily) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    daily.date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${daily.count} orders'),
                  trailing: Chip(
                    label: Text('${daily.count}'),
                    backgroundColor: daily.count > 0
                        ? Colors.blue
                        : Colors.grey,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _showOrderIdsDialog(daily.date, daily.orderIds);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showOrderIdsDialog(String date, List<String> orderIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Orders on $date'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: orderIds.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text('${index + 1}'),
                ),
                title: Text('Order #${orderIds[index]}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No orders found for selected dates',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset to last 7 days'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchAnalysis, child: const Text('Retry')),
        ],
      ),
    );
  }
}
