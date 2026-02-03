import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/service_station_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/service_sation/service_station_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/service_sation/service_station_event.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/service_sation/service_station_state.dart';

@RoutePage()
class ServiceStationScreen extends StatefulWidget {
  const ServiceStationScreen({super.key});

  @override
  State<ServiceStationScreen> createState() => _ServiceStationScreenState();
}

class _ServiceStationScreenState extends State<ServiceStationScreen> {
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late ServiceStationBloc _serviceStationBloc;

  @override
  void initState() {
    super.initState();
    _serviceStationBloc = context.read<ServiceStationBloc>();
    _scrollController.addListener(_onScroll);

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
    if (query.isNotEmpty) {
      _serviceStationBloc.add(
        FetchServiceStationEvent(page: '1', searchQuery: query),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _serviceStationBloc.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Service Stations'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, district, area...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      fillColor: Colors.grey.shade50,
                      filled: true,
                    ),
                    onSubmitted: (_) => _onSearchSubmitted(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearchSubmitted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<ServiceStationBloc, ServiceStationState>(
              listener: (context, state) {
                if (state is ServiceStationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
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
        padding: const EdgeInsets.all(8.0),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildShimmerCard();
        },
      ),
    );
  }

  Widget _buildSearchEmpty() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No results found for "${_searchController.text}"',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _clearSearch(),
                  child: const Text('Clear Search'),
                ),
              ],
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

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Results: ${serviceStations.count} found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearSearch,
                  tooltip: 'Clear search',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
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
        padding: const EdgeInsets.all(8.0),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildShimmerCard();
        },
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _serviceStationBloc.add(FetchServiceStationEvent(page: '1'));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No service stations found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: _onRefresh, child: const Text('Refresh')),
              ],
            ),
          ),
        ),
      ),
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
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (isPaginateError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _serviceStationBloc.loadNextPage();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerWidget(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.7,
              margin: const EdgeInsets.only(bottom: 8),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: _ShimmerWidget(
                height: 30,
                width: 80,
                margin: const EdgeInsets.only(bottom: 8),
              ),
            ),

            Row(
              children: [
                _ShimmerWidget(
                  height: 16,
                  width: 16,
                  margin: const EdgeInsets.only(right: 4),
                ),
                Expanded(
                  child: _ShimmerWidget(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                _ShimmerWidget(
                  height: 16,
                  width: 16,
                  margin: const EdgeInsets.only(right: 4),
                ),
                Expanded(
                  child: _ShimmerWidget(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _ShimmerWidget(
              height: 16,
              width: 120,
              margin: const EdgeInsets.only(bottom: 4),
            ),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(
                2,
                (index) => _ShimmerWidget(height: 32, width: 80),
              ),
            ),
          ],
        ),
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
      duration: const Duration(milliseconds: 1500),
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
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class _ServiceStationCard extends StatelessWidget {
  final ServiceStationEntity serviceStation;

  const _ServiceStationCard({required this.serviceStation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    serviceStation.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    'Rs.${serviceStation.baseCharge.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.location_on,
              text:
                  '${serviceStation.district} • ${serviceStation.areaCovered}',
            ),

            const SizedBox(height: 8),

            _buildInfoRow(
              icon: Icons.access_time,
              text: 'Arrival: ${serviceStation.arrivalTime}',
            ),

            if (serviceStation.phoneNumbers.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Contact Numbers:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: serviceStation.phoneNumbers.entries.map((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ),
      ],
    );
  }
}
