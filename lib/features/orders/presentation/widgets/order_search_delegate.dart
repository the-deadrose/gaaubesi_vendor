import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/search/search_empty_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/search/search_highlight_text.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/search/search_result_item.dart';

/// Search delegate for orders with custom UI and search history.
class OrderSearchDelegate extends SearchDelegate<OrderEntity?> {
  final List<OrderEntity> allOrders;
  final List<String> recentSearches;
  final Function(String) onSearchQueryChanged;
  final VoidCallback? onClearRecentSearches;

  OrderSearchDelegate({
    required this.allOrders,
    this.recentSearches = const [],
    required this.onSearchQueryChanged,
    this.onClearRecentSearches,
  }) : super(
         searchFieldLabel: 'Search orders...',
         searchFieldStyle: const TextStyle(fontSize: 16),
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
    final results = _searchOrders(query);

    if (results.isEmpty) {
      return const SearchEmptyState(message: 'No orders found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final order = results[index];
        return SearchResultItem(
          order: order,
          onTap: () => close(context, order),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }

    final suggestions = _searchOrders(query).take(5).toList();

    if (suggestions.isEmpty) {
      return const SearchEmptyState(message: 'No suggestions');
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final order = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search_rounded),
          title: HighlightedText(text: '${order.orderId}', query: query),
          subtitle: Text(
            order.receiverName,
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            query = order.orderId.toString();
            showResults(context);
          },
        );
      },
    );
  }

  List<OrderEntity> _searchOrders(String searchQuery) {
    if (searchQuery.isEmpty) return [];

    final lowerQuery = searchQuery.toLowerCase();
    return allOrders.where((order) {
      return order.orderId.toString().contains(lowerQuery) ||
          order.receiverName.toLowerCase().contains(lowerQuery) ||
          order.receiverAddress.toLowerCase().contains(lowerQuery) ||
          order.receiverNumber.toLowerCase().contains(lowerQuery);
    }).toList();
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
          (search) => ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(search),
            trailing: const Icon(Icons.north_west_rounded, size: 16),
            onTap: () {
              query = search;
              showResults(context);
            },
          ),
        ),
      ],
    );
  }
}
