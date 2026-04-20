import 'package:flutter/widgets.dart';

typedef OrdersFilterOpener = void Function();

class OrdersFilterBus {
  final Map<int, OrdersFilterOpener> _openers = {};

  void register(int tabIndex, OrdersFilterOpener opener) {
    _openers[tabIndex] = opener;
  }

  void unregister(int tabIndex, OrdersFilterOpener opener) {
    if (_openers[tabIndex] == opener) {
      _openers.remove(tabIndex);
    }
  }

  bool canOpen(int tabIndex) => _openers.containsKey(tabIndex);

  bool openFilter(int tabIndex) {
    final opener = _openers[tabIndex];
    if (opener == null) return false;
    opener();
    return true;
  }
}

class OrdersFilterScope extends InheritedWidget {
  final OrdersFilterBus bus;

  const OrdersFilterScope({
    super.key,
    required this.bus,
    required super.child,
  });

  static OrdersFilterBus? of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<OrdersFilterScope>();
    return scope?.bus;
  }

  @override
  bool updateShouldNotify(OrdersFilterScope oldWidget) =>
      bus != oldWidget.bus;
}
