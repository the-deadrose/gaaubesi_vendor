import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/sales/sales_report_analysis_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/sales/sales_report_analysis_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/sales/sales_report_analysis_state.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/sales_report_analysis_entity.dart';

@RoutePage()
class SalesReportAnalysisScreen extends StatefulWidget {
  const SalesReportAnalysisScreen({super.key});

  @override
  State<SalesReportAnalysisScreen> createState() =>
      _SalesReportAnalysisScreenState();
}

class _SalesReportAnalysisScreenState extends State<SalesReportAnalysisScreen> {
  late DateTime _selectedFromDate;
  late DateTime _selectedToDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedFromDate = DateTime(now.year, now.month, 1);
    _selectedToDate = now;
    _fetchData();
  }

  void _fetchData() {
    BlocProvider.of<SalesReportAnalysisBloc>(context).add(
      FetchSalesReportAnalysisEvent(
        startDate: _dateFormat.format(_selectedFromDate),
        endDate: _dateFormat.format(_selectedToDate),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _selectedFromDate : _selectedToDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _selectedFromDate = picked;
          // Check if the date range exceeds 180 days
          if (_selectedFromDate.isAfter(_selectedToDate)) {
            _selectedToDate = _selectedFromDate;
          } else if (_selectedToDate.difference(_selectedFromDate).inDays > 180) {
            // If range exceeds 180 days, limit to date 180 days after from date
            _selectedToDate = _selectedFromDate.add(const Duration(days: 180));
          }
        } else {
          _selectedToDate = picked;
          // Check if the date range exceeds 180 days
          if (_selectedToDate.isBefore(_selectedFromDate)) {
            _selectedFromDate = _selectedToDate;
          } else if (_selectedToDate.difference(_selectedFromDate).inDays > 180) {
            // If range exceeds 180 days, limit to date 180 days before to date
            _selectedFromDate = _selectedToDate.subtract(const Duration(days: 180));
          }
        }
      });
      
      if (_selectedToDate.difference(_selectedFromDate).inDays > 180) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date range cannot exceed 180 days (6 months)'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report Analysis'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Date Filter Section
          _buildDateFilterSection(),
          const SizedBox(height: 16),
          Expanded(
            child:
                BlocBuilder<SalesReportAnalysisBloc, SalesReportAnalysisState>(
                  builder: (context, state) {
                    if (state is SalesReportAnalysisLoading) {
                      return _buildShimmerLoading();
                    } else if (state is SalesReportAnalysisError) {
                      return _buildErrorWidget(state.message);
                    } else if (state is SalesReportAnalysisEmpty) {
                      return _buildEmptyWidget();
                    } else if (state is SalesReportAnalysisLoaded) {
                      return _buildSalesReportContent(
                        state.salesReportAnalysis,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
          ),
        ],
      ),
    );
  }

  // Loading shimmer without using shimmer package
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Shimmer for summary cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: List.generate(6, (index) => _buildShimmerCard()),
            ),
            const SizedBox(height: 24),
            // Shimmer for charts
            _buildShimmerChart('Daily Sales Trend'),
            const SizedBox(height: 24),
            _buildShimmerChart('Daily Orders'),
            const SizedBox(height: 24),
            // Shimmer for table
            _buildShimmerTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerChart(String title) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTable() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
                          color: Colors.grey[300],
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
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Data Available',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'No sales data found for the selected period',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerButton(
                    'From: ${DateFormat('MMM dd, yyyy').format(_selectedFromDate)}',
                    () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePickerButton(
                    'To: ${DateFormat('MMM dd, yyyy').format(_selectedToDate)}',
                    () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesReportContent(SalesReportAnalysis report) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(report),
            const SizedBox(height: 24),
            // Sales Chart
            _buildSalesChart(report.dailyReports),
            const SizedBox(height: 24),
            // Orders Chart
            _buildOrdersChart(report.dailyReports),
            const SizedBox(height: 24),
            // Daily Report Table
            _buildDailyReportTable(report.dailyReports),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(SalesReportAnalysis report) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildSummaryCard(
          'Total Orders',
          '${report.totalOrders}',
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Delivered',
          '${report.totalDeliveredOrders}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildSummaryCard(
          'Returned',
          '${report.totalReturnedOrders}',
          Icons.undo,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Total Sales',
          '\$${report.totalSales.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.purple,
        ),
        _buildSummaryCard(
          'Package Value',
          '\$${report.totalPackageValue.toStringAsFixed(2)}',
          Icons.check_box_outline_blank,
          Colors.teal,
        ),
        _buildSummaryCard(
          'Delivery Rate',
          '${_calculateDeliveryRate(report.totalOrders, report.totalDeliveredOrders)}%',
          Icons.trending_up,
          Colors.green,
        ),
      ],
    );
  }

  String _calculateDeliveryRate(int totalOrders, int deliveredOrders) {
    if (totalOrders == 0) return '0.0';
    return ((deliveredOrders / totalOrders) * 100).toStringAsFixed(1);
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(List<DailySalesReport> dailyReports) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Sales Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildCustomChart(dailyReports, isSalesChart: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersChart(List<DailySalesReport> dailyReports) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Orders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildCustomChart(dailyReports, isSalesChart: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomChart(
    List<DailySalesReport> reports, {
    required bool isSalesChart,
  }) {
    double maxValue = isSalesChart
        ? reports.map((r) => r.sales).reduce((a, b) => a > b ? a : b)
        : (reports.map((r) => r.totalOrders.toDouble()).reduce((a, b) => a > b ? a : b));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Total Orders', Colors.blue),
            const SizedBox(width: 16),
            _buildLegendItem('Delivered', Colors.green),
          ],
        ),
        const SizedBox(height: 8),
        // Chart area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomPaint(
              painter: _ChartPainter(
                reports: reports,
                maxValue: maxValue,
                isSalesChart: isSalesChart,
              ),
            ),
          ),
        ),
        // X-axis labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: reports
                .map(
                  (r) => Text(
                    DateFormat('MMM dd').format(r.createdDate),
                    style: const TextStyle(fontSize: 10),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDailyReportTable(List<DailySalesReport> dailyReports) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Report Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  return Colors.blue.withValues(alpha: 0.1);
                }),
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Total Orders'), numeric: true),
                  DataColumn(label: Text('Delivered'), numeric: true),
                  DataColumn(label: Text('Returned'), numeric: true),
                  DataColumn(label: Text('Package Value'), numeric: true),
                  DataColumn(label: Text('Sales'), numeric: true),
                ],
                rows: dailyReports.map((report) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          DateFormat('MMM dd, yyyy').format(report.createdDate),
                        ),
                      ),
                      DataCell(Text('${report.totalOrders}')),
                      DataCell(Text('${report.deliveredOrders}')),
                      DataCell(Text('${report.returnedOrders}')),
                      DataCell(
                        Text('\$${report.packageValue.toStringAsFixed(2)}'),
                      ),
                      DataCell(Text('\$${report.sales.toStringAsFixed(2)}')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<DailySalesReport> reports;
  final double maxValue;
  final bool isSalesChart;

  _ChartPainter({
    required this.reports,
    required this.maxValue,
    required this.isSalesChart,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    if (reports.isEmpty) return;

    final double stepX = size.width / (reports.length - 1);
    final double scaleY = size.height / maxValue;

    final List<Offset> points = [];
    for (int i = 0; i < reports.length; i++) {
      double value = isSalesChart
          ? reports[i].sales
          : reports[i].totalOrders.toDouble();
      double x = i * stepX;
      double y = size.height - (value * scaleY);
      points.add(Offset(x, y));
    }

    // Draw filled area
    final path = Path();
    path.moveTo(0, size.height);
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 3, Paint()..color = Colors.blue);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
