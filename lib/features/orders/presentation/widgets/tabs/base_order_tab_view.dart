import 'package:flutter/material.dart';

/// Abstract base class for order tab views with common scroll/refresh logic.
///
/// Subclasses must implement:
/// - [onLoadMore] - Called when scroll reaches bottom for pagination
/// - [onRefresh] - Called on pull-to-refresh
/// - [buildSlivers] - Returns the list of slivers to display
abstract class BaseOrderTabView extends StatefulWidget {
  const BaseOrderTabView({super.key});
}

abstract class BaseOrderTabViewState<T extends BaseOrderTabView>
    extends State<T>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// Called when user scrolls to bottom (90% threshold)
  void onLoadMore();

  /// Called on pull-to-refresh
  Future<void> onRefresh();

  /// Build the slivers to display in the CustomScrollView
  List<Widget> buildSlivers(BuildContext context);

  /// Check if scroll position is near the bottom
  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom) {
      onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: buildSlivers(context),
      ),
    );
  }
}
