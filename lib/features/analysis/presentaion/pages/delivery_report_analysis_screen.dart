import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/daily/delivery_report_analysis_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/daily/delivery_report_analysis_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/daily/delivery_report_analysis_state.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DeliveryReportAnalysisScreen extends StatefulWidget {
  const DeliveryReportAnalysisScreen({super.key});

  @override
  State<DeliveryReportAnalysisScreen> createState() =>
      _DeliveryReportAnalysisScreenState();
}

class _DeliveryReportAnalysisScreenState
    extends State<DeliveryReportAnalysisScreen> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    final now = DateTime.now();
    _selectedEndDate = now;
    _selectedStartDate = now.subtract(const Duration(days: 6));

    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedStartDate!);
    _endDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedEndDate!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDeliveryReport();
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _selectedStartDate : _selectedEndDate;
    final firstDate = isStartDate
        ? DateTime(2020)
        : (_selectedStartDate ?? DateTime(2020));
    final lastDate = isStartDate
        ? (_selectedEndDate ?? DateTime.now())
        : DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      if (isStartDate) {
        _selectedStartDate = pickedDate;
        _startDateController.text = formattedDate;
      } else {
        _selectedEndDate = pickedDate;
        _endDateController.text = formattedDate;
      }
    }
  }

  void _fetchDeliveryReport() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      final startDate = DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
      final endDate = DateFormat('yyyy-MM-dd').format(_selectedEndDate!);

      if (_selectedStartDate!.isAfter(_selectedEndDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Start date cannot be after end date')),
        );
        return;
      }

      context.read<DeliveryReportAnalysisBloc>().add(
        FetchDeliveryReportAnalysisEvent(
          startDate: startDate,
          endDate: endDate,
        ),
      );
    }
  }

  void _reset() {
    context.read<DeliveryReportAnalysisBloc>().add(
      const ResetDeliveryReportAnalysisEvent(),
    );
    final now = DateTime.now();
    _selectedEndDate = now;
    _selectedStartDate = now.subtract(const Duration(days: 6));
    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedStartDate!);
    _endDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedEndDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Report Analysis'),
        centerTitle: true,
      ),
      body:
          BlocConsumer<DeliveryReportAnalysisBloc, DeliveryReportAnalysisState>(
            listener: (context, state) {
              if (state is DeliveryReportAnalysisErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  // Date Filter Section
                  _buildDateFilterSection(),

                  const SizedBox(height: 16),

                  // Main Content
                  Expanded(child: _buildContent(state)),
                ],
              );
            },
          ),
    );
  }

  Widget _buildDateFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, true),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, false),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _fetchDeliveryReport,
                  icon: const Icon(Icons.search),
                  label: const Text('Fetch Report'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DeliveryReportAnalysisState state) {
    if (state is DeliveryReportAnalysisLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DeliveryReportAnalysisErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is DeliveryReportAnalysisEmptyState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No delivery data found for the selected date range',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is DeliveryReportAnalysisLoadedState) {
      final report = state.deliveryReportAnalysis;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Cards
              _buildSummaryCards(report),

              const SizedBox(height: 24),

              // Daily Reports
              _buildDailyReportsSection(report),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Select dates to view delivery report',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(DeliveryReportAnalysisEntity report) {
    return Column(
      children: [
        // Delivered Orders Summary
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Delivered Orders',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Count',
                      '${report.totalDeliveredOrders}',
                      Icons.format_list_numbered,
                    ),
                    _buildStatItem(
                      'Value',
                      report.totalDeliveredValue,
                      Icons.monetization_on,
                    ),
                    _buildStatItem(
                      'Charge',
                      report.totalDeliveredCharge,
                      Icons.local_shipping,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Returned Orders Summary
        Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.rotate_left, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Returned Orders',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Count',
                      '${report.totalReturnedOrders}',
                      Icons.format_list_numbered,
                    ),
                    _buildStatItem(
                      'Value',
                      report.totalReturnedValue,
                      Icons.monetization_on,
                    ),
                    _buildStatItem(
                      'Charge',
                      report.totalReturnedCharge,
                      Icons.local_shipping,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDailyReportsSection(DeliveryReportAnalysisEntity report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_view_day),
                const SizedBox(width: 8),
                Text(
                  'Daily Reports',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...report.dailyReports.map((dailyReport) {
              return _buildDailyReportTile(dailyReport);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyReportTile(DailyReportEntity dailyReport) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${dailyReport.deliveredOrders} Delivered',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Value: ${dailyReport.deliveredOrdersPackageValue}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Charge: ${dailyReport.deliveredOrdersDeliveryCharge}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Returns: ${dailyReport.returnedOrders}',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Return Value: ${dailyReport.returnedOrdersPackageValue}',
                    style: const TextStyle(fontSize: 12),
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
