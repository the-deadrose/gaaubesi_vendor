// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [BulkUploadOrdersPage]
class BulkUploadOrdersRoute extends PageRouteInfo<void> {
  const BulkUploadOrdersRoute({List<PageRouteInfo>? children})
    : super(BulkUploadOrdersRoute.name, initialChildren: children);

  static const String name = 'BulkUploadOrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BulkUploadOrdersPage();
    },
  );
}

/// generated route for
/// [CommentPage]
class CommentRoute extends PageRouteInfo<void> {
  const CommentRoute({List<PageRouteInfo>? children})
    : super(CommentRoute.name, initialChildren: children);

  static const String name = 'CommentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CommentPage();
    },
  );
}

/// generated route for
/// [CommentsPage]
class CommentsRoute extends PageRouteInfo<CommentsRouteArgs> {
  CommentsRoute({Key? key, int initialTab = 0, List<PageRouteInfo>? children})
    : super(
        CommentsRoute.name,
        args: CommentsRouteArgs(key: key, initialTab: initialTab),
        initialChildren: children,
      );

  static const String name = 'CommentsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CommentsRouteArgs>(
        orElse: () => const CommentsRouteArgs(),
      );
      return CommentsPage(key: args.key, initialTab: args.initialTab);
    },
  );
}

class CommentsRouteArgs {
  const CommentsRouteArgs({this.key, this.initialTab = 0});

  final Key? key;

  final int initialTab;

  @override
  String toString() {
    return 'CommentsRouteArgs{key: $key, initialTab: $initialTab}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CommentsRouteArgs) return false;
    return key == other.key && initialTab == other.initialTab;
  }

  @override
  int get hashCode => key.hashCode ^ initialTab.hashCode;
}

/// generated route for
/// [ContactPage]
class ContactRoute extends PageRouteInfo<void> {
  const ContactRoute({List<PageRouteInfo>? children})
    : super(ContactRoute.name, initialChildren: children);

  static const String name = 'ContactRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ContactPage();
    },
  );
}

/// generated route for
/// [CreateOrderPage]
class CreateOrderRoute extends PageRouteInfo<void> {
  const CreateOrderRoute({List<PageRouteInfo>? children})
    : super(CreateOrderRoute.name, initialChildren: children);

  static const String name = 'CreateOrderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateOrderPage();
    },
  );
}

/// generated route for
/// [CreateTicketScreen]
class CreateTicketRoute extends PageRouteInfo<void> {
  const CreateTicketRoute({List<PageRouteInfo>? children})
    : super(CreateTicketRoute.name, initialChildren: children);

  static const String name = 'CreateTicketRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateTicketScreen();
    },
  );
}

/// generated route for
/// [CustomerListScreen]
class CustomerListRoute extends PageRouteInfo<void> {
  const CustomerListRoute({List<PageRouteInfo>? children})
    : super(CustomerListRoute.name, initialChildren: children);

  static const String name = 'CustomerListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CustomerListScreen();
    },
  );
}

/// generated route for
/// [ExtraMileagePage]
class ExtraMileageRoute extends PageRouteInfo<void> {
  const ExtraMileageRoute({List<PageRouteInfo>? children})
    : super(ExtraMileageRoute.name, initialChildren: children);

  static const String name = 'ExtraMileageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ExtraMileagePage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MainScaffoldPage]
class MainScaffoldRoute extends PageRouteInfo<void> {
  const MainScaffoldRoute({List<PageRouteInfo>? children})
    : super(MainScaffoldRoute.name, initialChildren: children);

  static const String name = 'MainScaffoldRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScaffoldPage();
    },
  );
}

/// generated route for
/// [NoticeDetailScreen]
class NoticeDetailRoute extends PageRouteInfo<NoticeDetailRouteArgs> {
  NoticeDetailRoute({
    Key? key,
    required Notice notice,
    List<PageRouteInfo>? children,
  }) : super(
         NoticeDetailRoute.name,
         args: NoticeDetailRouteArgs(key: key, notice: notice),
         initialChildren: children,
       );

  static const String name = 'NoticeDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoticeDetailRouteArgs>();
      return NoticeDetailScreen(key: args.key, notice: args.notice);
    },
  );
}

class NoticeDetailRouteArgs {
  const NoticeDetailRouteArgs({this.key, required this.notice});

  final Key? key;

  final Notice notice;

  @override
  String toString() {
    return 'NoticeDetailRouteArgs{key: $key, notice: $notice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NoticeDetailRouteArgs) return false;
    return key == other.key && notice == other.notice;
  }

  @override
  int get hashCode => key.hashCode ^ notice.hashCode;
}

/// generated route for
/// [NoticeListScreen]
class NoticeListRoute extends PageRouteInfo<void> {
  const NoticeListRoute({List<PageRouteInfo>? children})
    : super(NoticeListRoute.name, initialChildren: children);

  static const String name = 'NoticeListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NoticeListScreen();
    },
  );
}

/// generated route for
/// [OrderDetailPage]
class OrderDetailRoute extends PageRouteInfo<OrderDetailRouteArgs> {
  OrderDetailRoute({
    Key? key,
    required int orderId,
    List<PageRouteInfo>? children,
  }) : super(
         OrderDetailRoute.name,
         args: OrderDetailRouteArgs(key: key, orderId: orderId),
         initialChildren: children,
       );

  static const String name = 'OrderDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OrderDetailRouteArgs>();
      return OrderDetailPage(key: args.key, orderId: args.orderId);
    },
  );
}

class OrderDetailRouteArgs {
  const OrderDetailRouteArgs({this.key, required this.orderId});

  final Key? key;

  final int orderId;

  @override
  String toString() {
    return 'OrderDetailRouteArgs{key: $key, orderId: $orderId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrderDetailRouteArgs) return false;
    return key == other.key && orderId == other.orderId;
  }

  @override
  int get hashCode => key.hashCode ^ orderId.hashCode;
}

/// generated route for
/// [OrdersPage]
class OrdersRoute extends PageRouteInfo<void> {
  const OrdersRoute({List<PageRouteInfo>? children})
    : super(OrdersRoute.name, initialChildren: children);

  static const String name = 'OrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrdersPage();
    },
  );
}

/// generated route for
/// [PaymentsPage]
class PaymentsRoute extends PageRouteInfo<void> {
  const PaymentsRoute({List<PageRouteInfo>? children})
    : super(PaymentsRoute.name, initialChildren: children);

  static const String name = 'PaymentsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PaymentsPage();
    },
  );
}

/// generated route for
/// [RedirectedOrdersPage]
class RedirectedOrdersRoute extends PageRouteInfo<void> {
  const RedirectedOrdersRoute({List<PageRouteInfo>? children})
    : super(RedirectedOrdersRoute.name, initialChildren: children);

  static const String name = 'RedirectedOrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RedirectedOrdersPage();
    },
  );
}

/// generated route for
/// [ReturnOrdersPage]
class ReturnOrdersRoute extends PageRouteInfo<void> {
  const ReturnOrdersRoute({List<PageRouteInfo>? children})
    : super(ReturnOrdersRoute.name, initialChildren: children);

  static const String name = 'ReturnOrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReturnOrdersPage();
    },
  );
}

/// generated route for
/// [StaleOrdersPage]
class StaleOrdersRoute extends PageRouteInfo<void> {
  const StaleOrdersRoute({List<PageRouteInfo>? children})
    : super(StaleOrdersRoute.name, initialChildren: children);

  static const String name = 'StaleOrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StaleOrdersPage();
    },
  );
}

/// generated route for
/// [TicketDetailScreen]
class TicketDetailRoute extends PageRouteInfo<TicketDetailRouteArgs> {
  TicketDetailRoute({
    Key? key,
    required PendingTicketEntity ticket,
    String? category,
    List<PageRouteInfo>? children,
  }) : super(
         TicketDetailRoute.name,
         args: TicketDetailRouteArgs(
           key: key,
           ticket: ticket,
           category: category,
         ),
         initialChildren: children,
       );

  static const String name = 'TicketDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TicketDetailRouteArgs>();
      return TicketDetailScreen(
        key: args.key,
        ticket: args.ticket,
        category: args.category,
      );
    },
  );
}

class TicketDetailRouteArgs {
  const TicketDetailRouteArgs({this.key, required this.ticket, this.category});

  final Key? key;

  final PendingTicketEntity ticket;

  final String? category;

  @override
  String toString() {
    return 'TicketDetailRouteArgs{key: $key, ticket: $ticket, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TicketDetailRouteArgs) return false;
    return key == other.key &&
        ticket == other.ticket &&
        category == other.category;
  }

  @override
  int get hashCode => key.hashCode ^ ticket.hashCode ^ category.hashCode;
}

/// generated route for
/// [TicketScreen]
class TicketRoute extends PageRouteInfo<TicketRouteArgs> {
  TicketRoute({Key? key, String? subject, List<PageRouteInfo>? children})
    : super(
        TicketRoute.name,
        args: TicketRouteArgs(key: key, subject: subject),
        rawQueryParams: {'subject': subject},
        initialChildren: children,
      );

  static const String name = 'TicketRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<TicketRouteArgs>(
        orElse: () =>
            TicketRouteArgs(subject: queryParams.optString('subject')),
      );
      return TicketScreen(key: args.key, subject: args.subject);
    },
  );
}

class TicketRouteArgs {
  const TicketRouteArgs({this.key, this.subject});

  final Key? key;

  final String? subject;

  @override
  String toString() {
    return 'TicketRouteArgs{key: $key, subject: $subject}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TicketRouteArgs) return false;
    return key == other.key && subject == other.subject;
  }

  @override
  int get hashCode => key.hashCode ^ subject.hashCode;
}

/// generated route for
/// [UtilitiesPage]
class UtilitiesRoute extends PageRouteInfo<void> {
  const UtilitiesRoute({List<PageRouteInfo>? children})
    : super(UtilitiesRoute.name, initialChildren: children);

  static const String name = 'UtilitiesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UtilitiesPage();
    },
  );
}
