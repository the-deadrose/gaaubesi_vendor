import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gaaubesi_vendor/core/presentation/widgets/error_view.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaaubesi_vendor/features/home/domain/entities/vendor_stats_entity.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_bloc.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_event.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeLoadStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      appBar: AppBar(
        backgroundColor: AppTheme.marianBlue,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 4,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.marianBlue,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: BlocSelector<HomeBloc, HomeState, bool>(
          selector: (s) => s is HomeError,
          builder: (context, isError) => isError
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  onPressed: () => context
                      .findRootAncestorStateOfType<ScaffoldState>()
                      ?.openDrawer(),
                ),
        ),
        title: BlocSelector<HomeBloc, HomeState, String?>(
          selector: (s) {
            if (s is HomeLoaded) return s.stats.vendorName;
            if (s is HomeRefreshing) return s.stats.vendorName;
            return null;
          },
          builder: (context, vendorName) {
            if (vendorName == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greetingForNow(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vendorName,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
        actions: [
          BlocSelector<HomeBloc, HomeState, bool>(
            selector: (s) => s is HomeError,
            builder: (context, isError) => isError
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        context.router.push(const NoticeListRoute()),
                  ),
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
            debugPrint(
              '[HomePage] BlocBuilder rebuild — state=${state.runtimeType}, '
              'blocInstance=${identityHashCode(context.read<HomeBloc>())}, '
              'todayOrderCreated='
              '${state is HomeLoaded
                  ? state.stats.todayOrderCreated
                  : state is HomeRefreshing
                  ? state.stats.todayOrderCreated
                  : 'n/a'}',
            );
            if (state is HomeLoading) {
              return const _LoadingState();
            }
            if (state is HomeError) {
              return ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<HomeBloc>().add(const HomeLoadStats()),
              );
            }
            if (state is HomeLoaded) {
              return _LoadedState(stats: state.stats);
            }
            if (state is HomeRefreshing) {
              return _LoadedState(stats: state.stats);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOADED STATE
// ─────────────────────────────────────────────

class _LoadedState extends StatelessWidget {
  final VendorStatsEntity stats;
  const _LoadedState({required this.stats});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.marianBlue,
      onRefresh: () async {
        final completer = Completer<void>();
        context.read<HomeBloc>().add(HomeRefreshStats(completer: completer));
        await completer.future;
      },
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _HeroHeader(stats: stats),
          const SizedBox(height: 20),
          _SectionLabel(text: "Today's activity"),
          const SizedBox(height: 12),
          _TodayStrip(stats: stats),
          const SizedBox(height: 28),
          _SectionLabel(text: 'Performance'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PerformanceCard(stats: stats),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ProcessingStagesCard(processing: stats.processingOrders),
          ),
          const SizedBox(height: 28),
          _SectionLabel(text: 'Finance'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FinanceCard(stats: stats),
          ),
          const SizedBox(height: 28),
          _SectionLabel(text: 'Packages'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PackagesCard(stats: stats),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ReturnsCard(stats: stats),
          ),
          const SizedBox(height: 28),
          _SectionLabel(text: 'Order status'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _OrderStatusCard(stats: stats),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────

class _HeroHeader extends StatefulWidget {
  final VendorStatsEntity stats;
  const _HeroHeader({required this.stats});

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader> {
  bool _showCod = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.marianBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   _greetingForNow(),
          //   style: TextStyle(
          //     fontSize: 13,
          //     color: Colors.white.withValues(alpha: 0.7),
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          // const SizedBox(height: 4),
          // Text(
          //   widget.stats.vendorName,
          //   style: const TextStyle(
          //     fontSize: 22,
          //     color: Colors.white,
          //     fontWeight: FontWeight.w700,
          //     letterSpacing: -0.3,
          //   ),
          // ),
          // const SizedBox(height: 24),
          _PendingCodBanner(
            amount: widget.stats.pendingCod,
            lastDate: widget.stats.lasstCodDate,
            visible: _showCod,
            onToggle: () => setState(() => _showCod = !_showCod),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.local_shipping_outlined,
                  label: 'Add Order',
                  onTap: () => context.router.push(const CreateOrderRoute()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.payments_outlined,
                  label: 'COD Request',
                  onTap: () => context.router.push(const PaymentRequestRoute()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.confirmation_number_outlined,
                  label: 'New Ticket',
                  onTap: () => context.router.push(const CreateTicketRoute()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingCodBanner extends StatelessWidget {
  final double amount;
  final String lastDate;
  final bool visible;
  final VoidCallback onToggle;

  const _PendingCodBanner({
    required this.amount,
    required this.lastDate,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending COD',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  visible ? 'Rs ${_fmtMoney(amount)}' : 'Rs ••••••',
                  style: GoogleFonts.spaceGrotesk(
                    textStyle: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last transfer · $lastDate',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              visible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white.withValues(alpha: 0.85),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.marianBlue, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.blackBean,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.darkGray,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TODAY'S ACTIVITY (horizontal strip)
// ─────────────────────────────────────────────

class _TodayStrip extends StatelessWidget {
  final VendorStatsEntity stats;
  const _TodayStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _TodayTile(
        icon: Icons.check_circle_outline,
        value: stats.todayDelivery,
        label: 'Delivered',
        tint: AppTheme.successGreen,
      ),
      _TodayTile(
        icon: Icons.assignment_return_outlined,
        value: stats.todaysReturnedDelivery,
        label: 'Returned',
        tint: AppTheme.rojo,
      ),
      _TodayTile(
        icon: Icons.add_box_outlined,
        value: stats.todayOrderCreated,
        label: 'Created',
        tint: AppTheme.marianBlue,
      ),
      _TodayTile(
        icon: Icons.chat_bubble_outline,
        value: stats.todaysComment,
        label: 'Comments',
        tint: AppTheme.infoBlue,
      ),
      _TodayTile(
        icon: Icons.pause_circle_outline,
        value: stats.totalHoldOrder,
        label: 'On Hold',
        tint: AppTheme.warningYellow,
      ),
      _TodayTile(
        icon: Icons.hourglass_bottom,
        value: stats.staleOrders,
        label: 'Stale',
        tint: AppTheme.darkGray,
      ),
    ];

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => tiles[i],
      ),
    );
  }
}

class _TodayTile extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color tint;
  const _TodayTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.disabledGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: tint),
          ),
          const Spacer(),
          Text(
            '$value',
            style: GoogleFonts.spaceGrotesk(
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackBean,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.powerBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PERFORMANCE CARD (consolidates Sales Stats + Success/Return chart)
// ─────────────────────────────────────────────

class _PerformanceCard extends StatelessWidget {
  final VendorStatsEntity stats;
  const _PerformanceCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final success = stats.successPercent;
    final returnP = stats.returnPercent;
    final other = math.max(0.0, 100 - success - returnP);

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Performance overview',
            subtitle: 'Success vs return rates',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 42,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: AppTheme.successGreen,
                            value: success,
                            radius: 18,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: AppTheme.rojo,
                            value: returnP,
                            radius: 18,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: AppTheme.disabledGray,
                            value: other,
                            radius: 18,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${success.toStringAsFixed(1)}%',
                          style: GoogleFonts.spaceGrotesk(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.blackBean,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'success',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.powerBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(
                      color: AppTheme.successGreen,
                      label: 'Success',
                      value: '${success.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendRow(
                      color: AppTheme.rojo,
                      label: 'Return',
                      value: '${returnP.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendRow(
                      color: AppTheme.disabledGray,
                      label: 'Other',
                      value: '${other.toStringAsFixed(1)}%',
                      labelColor: AppTheme.powerBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppTheme.disabledGray),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Redirect',
                  value: '${stats.redirectPercentage.toStringAsFixed(1)}%',
                ),
              ),
              Container(width: 1, height: 28, color: AppTheme.disabledGray),
              Expanded(
                child: _MiniStat(
                  label: 'Redirect return',
                  value:
                      '${stats.redirectOrderReturnedPercent.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROCESSING STAGES CARD
// ─────────────────────────────────────────────

class _ProcessingStagesCard extends StatelessWidget {
  final ProcessingOrdersEntity processing;
  const _ProcessingStagesCard({required this.processing});

  @override
  Widget build(BuildContext context) {
    final data = <Map<String, dynamic>>[
      {'stage': 'Drop Off', 'count': processing.dropOff},
      {'stage': 'Pickup', 'count': processing.pickup},
      {'stage': 'Dispatch', 'count': processing.dispatch},
      if (processing.hold > 0) {'stage': 'On Hold', 'count': processing.hold},
    ];
    final maxVal = data
        .map((e) => e['count'] as int)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Processing stages',
            subtitle: 'Current order distribution',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: const CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
                majorTickLines: MajorTickLines(size: 0),
                labelStyle: TextStyle(
                  fontSize: 11,
                  color: AppTheme.powerBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: (maxVal == 0 ? 10 : maxVal * 1.25),
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: AppTheme.disabledGray,
                  dashArray: [4, 4],
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.powerBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              series: <CartesianSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d['stage'] as String,
                  yValueMapper: (d, _) => d['count'] as int,
                  color: AppTheme.marianBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  width: 0.55,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                    textStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.whiteSmoke,
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

// ─────────────────────────────────────────────
// FINANCE CARD (consolidated COD details)
// ─────────────────────────────────────────────

class _FinanceCard extends StatefulWidget {
  final VendorStatsEntity stats;
  const _FinanceCard({required this.stats});

  @override
  State<_FinanceCard> createState() => _FinanceCardState();
}

class _FinanceCardState extends State<_FinanceCard> {
  bool _show = false;

  String _money(double v) => _show ? 'Rs ${_fmtMoney(v)}' : 'Rs ••••••';

  @override
  Widget build(BuildContext context) {
    final s = widget.stats;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _CardTitle(
                  title: 'Cash & charges',
                  subtitle: 'COD and delivery fees',
                ),
              ),
              _EyeToggle(
                visible: _show,
                onTap: () => setState(() => _show = !_show),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _KvRow(label: 'Pending COD', value: _money(s.pendingCod), bold: true),
          const SizedBox(height: 12),
          _KvRow(label: 'Last COD amount', value: _money(s.lastCodAmount)),
          const SizedBox(height: 12),
          _KvRow(label: 'Last COD transfer', value: s.lasstCodDate),
          const SizedBox(height: 12),
          _KvRow(
            label: 'Total delivery charges',
            value: _money(s.totalDelvCharge),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PACKAGES CARD (consolidated counts + value)
// ─────────────────────────────────────────────

class _PackagesCard extends StatefulWidget {
  final VendorStatsEntity stats;
  const _PackagesCard({required this.stats});

  @override
  State<_PackagesCard> createState() => _PackagesCardState();
}

class _PackagesCardState extends State<_PackagesCard> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.stats;
    final pct = s.totalPackages == 0
        ? 0.0
        : (s.deliveredPackages / s.totalPackages).clamp(0.0, 1.0);

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _CardTitle(
                  title: 'Packages',
                  subtitle: 'Counts and value',
                ),
              ),
              _EyeToggle(
                visible: _show,
                onTap: () => setState(() => _show = !_show),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total packages',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _show ? '${s.totalPackages}' : '••••',
                    style: GoogleFonts.spaceGrotesk(
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.blackBean,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total value',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _show ? 'Rs ${_fmtMoney(s.totalPackagesValue)}' : 'Rs ••••',
                    style: GoogleFonts.spaceGrotesk(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.blackBean,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            value: pct,
            label:
                '${(pct * 100).toStringAsFixed(1)}% delivered  ·  ${_show ? s.deliveredPackages : '••'} of ${_show ? s.totalPackages : '••'}',
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppTheme.disabledGray),
          const SizedBox(height: 16),
          _KvRow(
            label: 'Delivered value',
            value: _show ? 'Rs ${_fmtMoney(s.deliveredPackagesValue)}' : '••••',
          ),
          const SizedBox(height: 12),
          _KvRow(
            label: 'In delivery',
            value: _show ? '${s.ordersInDeliveryProcess}' : '••',
          ),
          const SizedBox(height: 12),
          _KvRow(
            label: 'In return process',
            value: _show ? '${s.ordersInReturnProcess}' : '••',
          ),
          const SizedBox(height: 12),
          _KvRow(
            label: 'Processing value',
            value: _show ? 'Rs ${_fmtMoney(s.ordersInProcessVal)}' : '••••',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RETURNS CARD
// ─────────────────────────────────────────────

class _ReturnsCard extends StatelessWidget {
  final VendorStatsEntity stats;
  const _ReturnsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final t = stats.trueReturnedPackages;
    final f = stats.falseReturnedPackages;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(title: 'Returns', subtitle: 'Successful and failed'),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ReturnPanel(
                  icon: Icons.check_circle,
                  tint: AppTheme.successGreen,
                  title: 'Successful',
                  count: t.count,
                  value: t.value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReturnPanel(
                  icon: Icons.cancel,
                  tint: AppTheme.rojo,
                  title: 'Failed',
                  count: f.count,
                  value: f.value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReturnPanel extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final int count;
  final double value;
  const _ReturnPanel({
    required this.icon,
    required this.tint,
    required this.title,
    required this.count,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tint),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: tint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: GoogleFonts.spaceGrotesk(
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackBean,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs ${_fmtMoney(value)}',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ORDER STATUS CARD
// ─────────────────────────────────────────────

class _OrderStatusCard extends StatelessWidget {
  final VendorStatsEntity stats;
  const _OrderStatusCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Order status',
            subtitle: 'RTV, hold and incoming',
          ),
          const SizedBox(height: 18),
          _KvRow(label: 'Total RTV', value: '${stats.totalRtvOrder}'),
          const SizedBox(height: 12),
          _KvRow(label: 'On hold', value: '${stats.totalHoldOrder}'),
          const SizedBox(height: 12),
          _KvRow(label: 'Incoming returns', value: '${stats.incomingReturns}'),
          const SizedBox(height: 12),
          _KvRow(
            label: 'Total redirect',
            value: '${stats.totalRedirectPercent.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED ATOMS
// ─────────────────────────────────────────────

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.disabledGray),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _CardTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.blackBean,
            letterSpacing: -0.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.powerBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _KvRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _KvRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            textStyle: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: AppTheme.blackBean,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final Color? labelColor;
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: labelColor ?? AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.powerBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EyeToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;
  const _EyeToggle({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: AppTheme.powerBlue,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final String label;
  const _ProgressBar({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppTheme.disabledGray,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.marianBlue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.powerBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// LOADING STATE (animated shimmer)
// ─────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Hero header placeholder — mirrors _HeroHeader structure
        Container(
          decoration: const BoxDecoration(
            color: AppTheme.marianBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Container(
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _Shimmer(width: 120, height: 12, radius: 6),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, _) =>
                const _Shimmer(width: 96, height: 108, radius: 18),
          ),
        ),
        const SizedBox(height: 28),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _Shimmer(width: 100, height: 12, radius: 6),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _Shimmer(height: 240, radius: 20),
              SizedBox(height: 16),
              _Shimmer(height: 220, radius: 20),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _Shimmer(width: 80, height: 12, radius: 6),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _Shimmer(height: 180, radius: 20),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double height;
  final double radius;
  final double? width;
  const _Shimmer({required this.height, required this.radius, this.width});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * t, 0),
              end: Alignment(1.0 + 2 * t, 0),
              colors: const [
                AppTheme.disabledGray,
                AppTheme.whiteSmoke,
                AppTheme.disabledGray,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

String _greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _fmtMoney(double amount) {
  if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
  if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
  if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
  return amount.toStringAsFixed(0);
}
