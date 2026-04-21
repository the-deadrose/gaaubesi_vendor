import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/service_station_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/service_sation/service_station_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/service_sation/service_station_event.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/service_sation/service_station_state.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ServiceStationScreen extends StatefulWidget {
  const ServiceStationScreen({super.key});

  @override
  State<ServiceStationScreen> createState() => _ServiceStationScreenState();
}

class _ServiceStationScreenState extends State<ServiceStationScreen> {
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late ServiceStationBloc _serviceStationBloc;

  @override
  void initState() {
    super.initState();
    _serviceStationBloc = context.read<ServiceStationBloc>();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _serviceStationBloc.add(FetchServiceStationEvent(page: '1'));
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _serviceStationBloc.loadNextPage();
    }
  }

  void _onRefresh() {
    _serviceStationBloc.add(
      RefreshServiceStationEvent(
        page: '1',
        searchQuery: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      ),
    );
  }

  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    _searchFocusNode.unfocus();
    if (query.isNotEmpty) {
      _serviceStationBloc.add(
        FetchServiceStationEvent(page: '1', searchQuery: query),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _serviceStationBloc.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.extra.lightGray,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        title: const Text(
          'Service Stations',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchHeader(theme),
          Expanded(
            child: BlocConsumer<ServiceStationBloc, ServiceStationState>(
              listener: (context, state) {
                if (state is ServiceStationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return _buildBody(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme) {
    final hasText = _searchController.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by name, district, area…',
                  hintStyle: TextStyle(
                    color: theme.extra.darkGray,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon: hasText
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: theme.extra.darkGray,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                onSubmitted: (_) => _onSearchSubmitted(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _onSearchSubmitted,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ServiceStationState state) {
    if (state is ServiceStationSearching) {
      return _buildSearchLoading();
    }

    if (state is ServiceStationSearchEmpty) {
      return _buildSearchEmpty();
    }

    if (state is ServiceStationSearchError &&
        state is! ServiceStationSearchLoaded) {
      return _buildSearchEmpty();
    }

    if (state is ServiceStationSearchLoaded) {
      return _buildSearchResults(state);
    }

    if (state is ServiceStationInitial || state is ServiceStationLoading) {
      return _buildLoadingScreen();
    }

    if (state is ServiceStationError && state is! ServiceStationLoaded) {
      return _buildErrorScreen(state.message);
    }

    if (state is ServiceStationEmpty) {
      return _buildEmptyScreen();
    }

    return _buildLoadedContent(state);
  }

  Widget _buildSearchLoading() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildSearchEmpty() {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _iconBubble(
                    Icons.search_off_rounded,
                    theme.extra.darkGray,
                    theme,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No matches found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We couldn\'t find any service station for "${_searchController.text}".',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.extra.darkGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Clear search'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ServiceStationSearchLoaded state) {
    final serviceStations = state.serviceStationList;
    final isLoadingMore = state is ServiceStationPaginating;
    final isPaginateError = state is ServiceStationPaginateError;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.extra.darkGray,
                      ),
                      children: [
                        const TextSpan(text: 'Showing '),
                        TextSpan(
                          text: '${serviceStations.count}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const TextSpan(text: ' result(s)'),
                      ],
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount:
                  serviceStations.results.length +
                  (isLoadingMore || isPaginateError ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= serviceStations.results.length) {
                  return _buildBottomLoader(
                    isLoadingMore: isLoadingMore,
                    isPaginateError: isPaginateError,
                    errorMessage: isPaginateError
                        ? 'Failed to load more results'
                        : null,
                  );
                }

                final station = serviceStations.results[index];
                return _ServiceStationCard(serviceStation: station);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _iconBubble(
              Icons.error_outline_rounded,
              theme.colorScheme.error,
              theme,
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: theme.extra.darkGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _serviceStationBloc.add(FetchServiceStationEvent(page: '1'));
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _iconBubble(
                    Icons.location_off_rounded,
                    theme.extra.darkGray,
                    theme,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No service stations available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pull down to refresh or try again in a moment.',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.extra.darkGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBubble(IconData icon, Color color, ThemeData theme) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 44, color: color),
    );
  }

  Widget _buildLoadedContent(ServiceStationState state) {
    ServiceStationListEntity serviceStations;
    bool isLoadingMore = false;
    bool isPaginateError = false;
    String? errorMessage;

    if (state is ServiceStationLoaded) {
      serviceStations = state.serviceStationList;
    } else if (state is ServiceStationPaginated) {
      serviceStations = state.serviceStationList;
    } else if (state is ServiceStationPaginateError) {
      final bloc = context.read<ServiceStationBloc>();
      if (bloc.currentServiceStations != null) {
        serviceStations = bloc.currentServiceStations!;
        isPaginateError = true;
        errorMessage = state.message;
      } else {
        return _buildErrorScreen(state.message);
      }
    } else if (state is ServiceStationPaginating) {
      final bloc = context.read<ServiceStationBloc>();
      if (bloc.currentServiceStations != null) {
        serviceStations = bloc.currentServiceStations!;
        isLoadingMore = true;
      } else {
        return _buildLoadingScreen();
      }
    } else {
      return _buildErrorScreen('Unexpected state occurred');
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount:
            serviceStations.results.length +
            (isLoadingMore || isPaginateError ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= serviceStations.results.length) {
            return _buildBottomLoader(
              isLoadingMore: isLoadingMore,
              isPaginateError: isPaginateError,
              errorMessage: errorMessage,
            );
          }

          final station = serviceStations.results[index];
          return _ServiceStationCard(serviceStation: station);
        },
      ),
    );
  }

  Widget _buildBottomLoader({
    required bool isLoadingMore,
    required bool isPaginateError,
    String? errorMessage,
  }) {
    final theme = Theme.of(context);
    if (isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    } else if (isPaginateError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(
              errorMessage ?? 'Failed to load more',
              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _serviceStationBloc.loadNextPage(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ShimmerWidget(
                  height: 18,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
              const SizedBox(width: 8),
              const _ShimmerWidget(height: 26, width: 70),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const _ShimmerWidget(
                height: 16,
                width: 16,
                margin: EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: _ShimmerWidget(
                  height: 14,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const _ShimmerWidget(
                height: 16,
                width: 16,
                margin: EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: _ShimmerWidget(
                  height: 14,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              2,
              (index) => const _ShimmerWidget(height: 32, width: 110),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerWidget extends StatefulWidget {
  final double height;
  final double width;
  final EdgeInsetsGeometry? margin;

  const _ShimmerWidget({
    required this.height,
    required this.width,
    this.margin,
  });

  @override
  State<_ShimmerWidget> createState() => __ShimmerWidgetState();
}

class __ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.grey[200],
      end: Colors.grey[350],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: _animation.value,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}

class _ServiceStationCard extends StatelessWidget {
  final ServiceStationEntity serviceStation;

  const _ServiceStationCard({required this.serviceStation});

  Future<void> _callNumber(BuildContext context, String number) async {
    final sanitized = number.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: sanitized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to place call')),
      );
    }
  }

  void _copyNumber(BuildContext context, String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $number'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phones = serviceStation.phoneNumbers.entries.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_shipping_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceStation.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.place_rounded,
                            size: 14,
                            color: theme.extra.darkGray,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              serviceStation.district,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: theme.extra.darkGray,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Rs ${serviceStation.baseCharge.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.extra.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Arrival',
                    value: serviceStation.arrivalTime.isEmpty
                        ? '—'
                        : serviceStation.arrivalTime,
                    iconColor: theme.colorScheme.primary,
                  ),
                  if (serviceStation.areaCovered.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.map_rounded,
                      label: 'Area covered',
                      value: serviceStation.areaCovered,
                      iconColor: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),

            if (phones.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.phone_in_talk_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Contact numbers',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: phones
                    .map(
                      (entry) => _PhoneChip(
                        label: entry.key,
                        number: entry.value,
                        onCall: () => _callNumber(context, entry.value),
                        onLongPress: () => _copyNumber(context, entry.value),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: theme.extra.darkGray,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneChip extends StatelessWidget {
  final String label;
  final String number;
  final VoidCallback onCall;
  final VoidCallback onLongPress;

  const _PhoneChip({
    required this.label,
    required this.number,
    required this.onCall,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onCall,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.call_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '$label · $number',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
