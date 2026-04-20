import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
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
  bool _filtersExpanded = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedStartDate = DateTime(now.year, now.month, 1);
    _selectedEndDate = now;
    _startDateController.text =
        DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
    _endDateController.text =
        DateFormat('yyyy-MM-dd').format(_selectedEndDate!);

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
            'Date range cannot exceed $maxDaysRange days. Current: ${difference + 1} days';
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.marianBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.blackBean,
            ),
          ),
          child: child!,
        );
      },
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

  void _applyPreset(int days) {
    final now = DateTime.now();
    _selectedEndDate = now;
    _selectedStartDate = now.subtract(Duration(days: days));
    _startDateController.text =
        DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
    _endDateController.text =
        DateFormat('yyyy-MM-dd').format(_selectedEndDate!);
    setState(() {
      _dateRangeError = null;
    });
    _fetchAnalysis();
  }

  void _applyMonthToDate() {
    final now = DateTime.now();
    _selectedStartDate = DateTime(now.year, now.month, 1);
    _selectedEndDate = now;
    _startDateController.text =
        DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
    _endDateController.text =
        DateFormat('yyyy-MM-dd').format(_selectedEndDate!);
    setState(() {
      _dateRangeError = null;
    });
    _fetchAnalysis();
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

  void _resetFilters() => _applyMonthToDate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(child: _buildFilterCard()),
          SliverToBoxAdapter(
            child:
                BlocBuilder<SalesReportAnalysisBloc, SalesReportAnalysisState>(
              builder: (context, state) {
                if (state is SalesReportAnalysisLoaded) {
                  return Column(
                    children: [
                      _buildSalesHero(state.salesReportAnalysis),
                      _buildStatsGrid(state.salesReportAnalysis),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          SliverToBoxAdapter(
            child:
                BlocBuilder<SalesReportAnalysisBloc, SalesReportAnalysisState>(
              builder: (context, state) => _buildContentBasedOnState(state),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: AppTheme.marianBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text(
        'Sales Report',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reset to current month',
          onPressed: _resetFilters,
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.marianBlue,
                Color(0xFF2E5BB8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_month_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDateRangeLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _rangeDaysLabel(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateRangeLabel() {
    if (_selectedStartDate == null || _selectedEndDate == null) return '';
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(_selectedStartDate!)}  →  ${fmt.format(_selectedEndDate!)}';
  }

  String _rangeDaysLabel() {
    if (_selectedStartDate == null || _selectedEndDate == null) return '';
    final days =
        _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;
    return '$days day${days == 1 ? '' : 's'} selected';
  }

  Widget _buildFilterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () =>
                setState(() => _filtersExpanded = !_filtersExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.marianBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        size: 18, color: AppTheme.marianBlue),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.blackBean,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _filtersExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.darkGray),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _filtersExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildFilterBody(),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_dateRangeError != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.rojo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppTheme.rojo.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppTheme.rojo, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _dateRangeError!,
                    style: const TextStyle(
                      color: AppTheme.rojo,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildMtdChip(),
              const SizedBox(width: 8),
              _buildPresetChip('7D', 7),
              const SizedBox(width: 8),
              _buildPresetChip('30D', 30),
              const SizedBox(width: 8),
              _buildPresetChip('90D', 90),
              const SizedBox(width: 8),
              _buildPresetChip('180D', 180),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                controller: _startDateController,
                label: 'From',
                onTap: () => _selectDate(context, true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.arrow_forward_rounded,
                  color: AppTheme.powerBlue.withValues(alpha: 0.8), size: 18),
            ),
            Expanded(
              child: _buildDateField(
                controller: _endDateController,
                label: 'To',
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMtdChip() {
    final now = DateTime.now();
    final isMtd = _selectedStartDate != null &&
        _selectedEndDate != null &&
        _selectedStartDate!.year == now.year &&
        _selectedStartDate!.month == now.month &&
        _selectedStartDate!.day == 1 &&
        _selectedEndDate!.year == now.year &&
        _selectedEndDate!.month == now.month &&
        _selectedEndDate!.day == now.day;
    return GestureDetector(
      onTap: _applyMonthToDate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isMtd ? AppTheme.marianBlue : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMtd
                ? AppTheme.marianBlue
                : AppTheme.powerBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          'MTD',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isMtd ? Colors.white : AppTheme.darkGray,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int days) {
    final currentRange = _selectedStartDate != null && _selectedEndDate != null
        ? _selectedEndDate!.difference(_selectedStartDate!).inDays
        : -1;
    final isActive = currentRange == days;
    return GestureDetector(
      onTap: () => _applyPreset(days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.marianBlue : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.marianBlue
                : AppTheme.powerBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppTheme.darkGray,
            letterSpacing: 0.3,
          ),
        ),
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
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppTheme.powerBlue.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 16, color: AppTheme.marianBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDatePretty(controller.text),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blackBean,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDatePretty(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('MMM d, yyyy').format(d);
    } catch (_) {
      return iso;
    }
  }

  Widget _buildSalesHero(SalesReportAnalysis analysis) {
    final currencyFmt = NumberFormat.currency(
        symbol: 'Rs.', decimalDigits: 0, locale: 'en_IN');
    final deliveryRate = analysis.totalOrders > 0
        ? (analysis.totalDeliveredOrders / analysis.totalOrders * 100)
            .toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.marianBlue,
            Color(0xFF2E5BB8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'TOTAL SALES',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currencyFmt.format(analysis.totalSales),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Package value: ${currencyFmt.format(analysis.totalPackageValue)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _heroStat(
                  label: 'Orders', value: '${analysis.totalOrders}'),
              _heroDivider(),
              _heroStat(
                  label: 'Delivered',
                  value: '${analysis.totalDeliveredOrders}'),
              _heroDivider(),
              _heroStat(label: 'Rate', value: '$deliveryRate%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat({required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }

  Widget _buildStatsGrid(SalesReportAnalysis analysis) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: '${analysis.totalOrders}',
                  label: 'Total Orders',
                  icon: Icons.shopping_cart_rounded,
                  color: AppTheme.infoBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: '${analysis.totalDeliveredOrders}',
                  label: 'Delivered',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: '${analysis.totalReturnedOrders}',
                  label: 'Returned',
                  icon: Icons.keyboard_return_rounded,
                  color: AppTheme.rojo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: '${analysis.dailyReports.length}',
                  label: 'Active Days',
                  icon: Icons.event_available_rounded,
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.blackBean,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
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
    return const SizedBox.shrink();
  }

  Widget _buildInitialView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.marianBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_rounded,
                size: 44, color: AppTheme.marianBlue),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ready to analyze',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick a date range to view your sales performance',
            style: TextStyle(fontSize: 13, color: AppTheme.darkGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildShimmerCard(height: 160),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerCard(height: 100)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard(height: 100)),
            ],
          ),
          const SizedBox(height: 12),
          _buildShimmerCard(height: 300),
          const SizedBox(height: 12),
          _buildShimmerCard(height: 300),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({double height = 120}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.marianBlue.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisView(SalesReportAnalysis analysis) {
    if (analysis.dailyReports.isEmpty) return _buildEmptyView();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSalesChart(analysis),
        _buildOrdersChart(analysis),
        _buildDailyDetailsSection(analysis),
      ],
    );
  }

  Widget _buildChartCard({
    required IconData icon,
    required String title,
    required String trailing,
    required Widget chart,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.marianBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppTheme.marianBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.blackBean,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  trailing,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }

  Widget _buildSalesChart(SalesReportAnalysis analysis) {
    final dailyReports = analysis.dailyReports;
    if (dailyReports.isEmpty) return const SizedBox();

    final currencyFmt =
        NumberFormat.compactCurrency(symbol: 'Rs.', decimalDigits: 0);

    return _buildChartCard(
      icon: Icons.show_chart_rounded,
      title: 'Daily Sales Trend',
      trailing: '${dailyReports.length} days',
      chart: SizedBox(
        height: 260,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          primaryXAxis: CategoryAxis(
            interval: 1,
            labelRotation: -45,
            labelIntersectAction: AxisLabelIntersectAction.rotate45,
            maximumLabels: 200,
            labelStyle: const TextStyle(
              fontSize: 10,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
          ),
          primaryYAxis: NumericAxis(
            labelStyle:
                const TextStyle(fontSize: 10, color: AppTheme.darkGray),
            majorGridLines: MajorGridLines(
              color: AppTheme.powerBlue.withValues(alpha: 0.2),
              width: 1,
              dashArray: const [4, 4],
            ),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            numberFormat: currencyFmt,
          ),
          series: <CartesianSeries<DailySalesReport, String>>[
            SplineAreaSeries<DailySalesReport, String>(
              dataSource: dailyReports,
              xValueMapper: (data, _) =>
                  DateFormat('MMM d').format(data.createdDate),
              yValueMapper: (data, _) => data.sales,
              name: 'Sales',
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.marianBlue.withValues(alpha: 0.35),
                  AppTheme.marianBlue.withValues(alpha: 0.02),
                ],
              ),
              borderColor: AppTheme.marianBlue,
              borderWidth: 2.5,
              animationDuration: 800,
            ),
            SplineSeries<DailySalesReport, String>(
              dataSource: dailyReports,
              xValueMapper: (data, _) =>
                  DateFormat('MMM d').format(data.createdDate),
              yValueMapper: (data, _) => data.sales,
              name: 'Sales',
              color: AppTheme.marianBlue,
              width: 2.5,
              markerSettings: const MarkerSettings(
                isVisible: true,
                height: 6,
                width: 6,
                shape: DataMarkerType.circle,
                borderWidth: 2,
                borderColor: Colors.white,
                color: AppTheme.marianBlue,
              ),
              animationDuration: 800,
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            header: '',
            canShowMarker: true,
            color: AppTheme.blackBean,
            textStyle: const TextStyle(color: Colors.white, fontSize: 11),
            borderWidth: 0,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              final p = data as DailySalesReport;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.blackBean,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(p.createdDate),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs.${p.sales.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersChart(SalesReportAnalysis analysis) {
    final dailyReports = analysis.dailyReports;
    if (dailyReports.isEmpty) return const SizedBox();

    return _buildChartCard(
      icon: Icons.bar_chart_rounded,
      title: 'Orders vs Delivered',
      trailing: '${analysis.totalOrders} orders',
      chart: SizedBox(
        height: 260,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          primaryXAxis: CategoryAxis(
            interval: 1,
            labelRotation: -45,
            labelIntersectAction: AxisLabelIntersectAction.rotate45,
            maximumLabels: 200,
            labelStyle: const TextStyle(
              fontSize: 10,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
          ),
          primaryYAxis: NumericAxis(
            labelStyle:
                const TextStyle(fontSize: 10, color: AppTheme.darkGray),
            majorGridLines: MajorGridLines(
              color: AppTheme.powerBlue.withValues(alpha: 0.2),
              width: 1,
              dashArray: const [4, 4],
            ),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
          ),
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.top,
            overflowMode: LegendItemOverflowMode.wrap,
            textStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
            iconHeight: 10,
            iconWidth: 10,
          ),
          series: <CartesianSeries<DailySalesReport, String>>[
            ColumnSeries<DailySalesReport, String>(
              dataSource: dailyReports,
              xValueMapper: (data, _) =>
                  DateFormat('MMM d').format(data.createdDate),
              yValueMapper: (data, _) => data.totalOrders.toDouble(),
              name: 'Total',
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E5BB8), AppTheme.marianBlue],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              width: 0.7,
              animationDuration: 700,
            ),
            ColumnSeries<DailySalesReport, String>(
              dataSource: dailyReports,
              xValueMapper: (data, _) =>
                  DateFormat('MMM d').format(data.createdDate),
              yValueMapper: (data, _) => data.deliveredOrders.toDouble(),
              name: 'Delivered',
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF43D17E), AppTheme.successGreen],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              width: 0.7,
              animationDuration: 700,
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            header: '',
            canShowMarker: false,
            color: AppTheme.blackBean,
            textStyle: const TextStyle(color: Colors.white, fontSize: 11),
            borderWidth: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyDetailsSection(SalesReportAnalysis analysis) {
    final reversed =
        List<DailySalesReport>.from(analysis.dailyReports).reversed.toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.marianBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.list_alt_rounded,
                    size: 16, color: AppTheme.marianBlue),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Daily Breakdown',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.blackBean,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${analysis.dailyReports.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...reversed.map(_buildDailyItem),
        ],
      ),
    );
  }

  Widget _buildDailyItem(DailySalesReport daily) {
    final deliveryRate = daily.totalOrders > 0
        ? (daily.deliveredOrders / daily.totalOrders * 100).toStringAsFixed(0)
        : '0';
    final dow = DateFormat('EEE').format(daily.createdDate);
    final dayNum = DateFormat('dd').format(daily.createdDate);
    final mon = DateFormat('MMM').format(daily.createdDate).toUpperCase();

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.powerBlue.withValues(alpha: 0.15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            collapsedIconColor: AppTheme.darkGray,
            iconColor: AppTheme.marianBlue,
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.marianBlue.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mon,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.marianBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    dayNum,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.blackBean,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              DateFormat('EEEE, MMM d').format(daily.createdDate),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackBean,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$dow • $deliveryRate% delivered',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs.${daily.sales.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: daily.sales > 0
                        ? AppTheme.successGreen
                        : AppTheme.darkGray,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${daily.totalOrders} orders',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            children: [
              _buildStackedBar(daily),
              const SizedBox(height: 12),
              _buildBreakdownRow(daily),
              const SizedBox(height: 10),
              _buildPackageRow(daily),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedBar(DailySalesReport daily) {
    final total = daily.totalOrders;
    if (total == 0) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.powerBlue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    final delivered = daily.deliveredOrders;
    final returned = daily.returnedOrders;
    final other = (total - delivered - returned).clamp(0, total);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            if (delivered > 0)
              Expanded(
                flex: delivered,
                child: Container(color: AppTheme.successGreen),
              ),
            if (other > 0)
              Expanded(
                flex: other,
                child: Container(color: const Color(0xFFFF9800)),
              ),
            if (returned > 0)
              Expanded(
                flex: returned,
                child: Container(color: AppTheme.rojo),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(DailySalesReport daily) {
    final total = daily.totalOrders;
    String pct(int v) =>
        total > 0 ? '${(v / total * 100).toStringAsFixed(0)}%' : '0%';
    final other =
        (total - daily.deliveredOrders - daily.returnedOrders).clamp(0, total);
    return Row(
      children: [
        Expanded(
          child: _statPill(
            color: AppTheme.successGreen,
            label: 'Delivered',
            value: '${daily.deliveredOrders}',
            percent: pct(daily.deliveredOrders),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _statPill(
            color: const Color(0xFFFF9800),
            label: 'Processing',
            value: '$other',
            percent: pct(other),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _statPill(
            color: AppTheme.rojo,
            label: 'Returned',
            value: '${daily.returnedOrders}',
            percent: pct(daily.returnedOrders),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageRow(DailySalesReport daily) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.powerBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_rounded,
              size: 16, color: AppTheme.darkGray),
          const SizedBox(width: 8),
          const Text(
            'Package Value',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'Rs.${daily.packageValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill({
    required Color color,
    required String label,
    required String value,
    required String percent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  percent,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.powerBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded,
                size: 44, color: AppTheme.powerBlue.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Sales Data',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No sales found for the selected date range',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.darkGray),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset to Current Month'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.marianBlue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.rojo.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded,
                size: 44, color: AppTheme.rojo),
          ),
          const SizedBox(height: 20),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.darkGray),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _fetchAnalysis,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.marianBlue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
