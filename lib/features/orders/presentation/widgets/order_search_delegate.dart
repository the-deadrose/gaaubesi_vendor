import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/search_orders_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_card.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/search/search_empty_state.dart';

class OrderSearchDelegate extends SearchDelegate<OrderEntity?> {
  final SearchOrdersUseCase searchOrdersUseCase;
  final List<String> recentSearches;
  final Function(String) onSearchQueryChanged;
  final VoidCallback? onClearRecentSearches;

  OrderSearchDelegate({
    required this.searchOrdersUseCase,
    this.recentSearches = const [],
    required this.onSearchQueryChanged,
    this.onClearRecentSearches,
  }) : super(
         searchFieldLabel: 'Search orders...',
         searchFieldStyle: const TextStyle(fontSize: 16, color: Colors.white),
         keyboardType: TextInputType.number,
       );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: 'Clear',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
      tooltip: 'Back',
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }

    if (query.trim().length < 2) {
      return const SearchEmptyState(
        message: 'Enter at least 2 characters',
        icon: Icons.keyboard_rounded,
      );
    }

    return FutureBuilder<List<OrderEntity>>(
      future: _performSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return SearchEmptyState(
            message: 'Search failed',
            icon: Icons.error_outline,
          );
        }

        final suggestions = snapshot.data ?? [];

        if (suggestions.isEmpty) {
          return const SearchEmptyState(
            message: 'No orders found',
            icon: Icons.search_off_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final order = suggestions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderCard(
                order: order,
                onTap: () {
                  context.router.push(OrderDetailRoute(orderId: order.orderId));
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<List<OrderEntity>> _performSearch(
    String searchQuery, {
    int? limit,
  }) async {
    if (searchQuery.trim().isEmpty) return [];

    final result = await searchOrdersUseCase(
      SearchOrdersParams(query: searchQuery.trim(), limit: limit),
    );

    return result.fold((_) => [], (orders) => orders);
  }

  Widget _buildRecentSearches(BuildContext context) {
    if (recentSearches.isEmpty) {
      return const SearchEmptyState(
        message: 'Start typing to search orders',
        icon: Icons.search_rounded,
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              if (onClearRecentSearches != null)
                TextButton(
                  onPressed: onClearRecentSearches,
                  child: const Text('Clear'),
                ),
            ],
          ),
        ),
        ...recentSearches.map(
          (search) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(search),
              trailing: const Icon(Icons.north_west_rounded, size: 16),
              onTap: () {
                query = search;
                showResults(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
