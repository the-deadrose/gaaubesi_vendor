// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CalculateDeliveryChargeScreen]
class CalculateDeliveryChargeRoute extends PageRouteInfo<void> {
  const CalculateDeliveryChargeRoute({List<PageRouteInfo>? children})
    : super(CalculateDeliveryChargeRoute.name, initialChildren: children);

  static const String name = 'CalculateDeliveryChargeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CalculateDeliveryChargeScreen();
    },
  );
}

/// generated route for
/// [ChangePasswordScreen]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordScreen();
    },
  );
}

/// generated route for
/// [CodTransferListScreen]
class CodTransferListRoute extends PageRouteInfo<void> {
  const CodTransferListRoute({List<PageRouteInfo>? children})
    : super(CodTransferListRoute.name, initialChildren: children);

  static const String name = 'CodTransferListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CodTransferListScreen();
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
/// [CustomerDetailScreen]
class CustomerDetailRoute extends PageRouteInfo<CustomerDetailRouteArgs> {
  CustomerDetailRoute({
    Key? key,
    required String customerId,
    List<PageRouteInfo>? children,
  }) : super(
         CustomerDetailRoute.name,
         args: CustomerDetailRouteArgs(key: key, customerId: customerId),
         rawPathParams: {'id': customerId},
         initialChildren: children,
       );

  static const String name = 'CustomerDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CustomerDetailRouteArgs>(
        orElse: () =>
            CustomerDetailRouteArgs(customerId: pathParams.getString('id')),
      );
      return CustomerDetailScreen(key: args.key, customerId: args.customerId);
    },
  );
}

class CustomerDetailRouteArgs {
  const CustomerDetailRouteArgs({this.key, required this.customerId});

  final Key? key;

  final String customerId;

  @override
  String toString() {
    return 'CustomerDetailRouteArgs{key: $key, customerId: $customerId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomerDetailRouteArgs) return false;
    return key == other.key && customerId == other.customerId;
  }

  @override
  int get hashCode => key.hashCode ^ customerId.hashCode;
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
/// [DailyTransactionScreen]
class DailyTransactionRoute extends PageRouteInfo<DailyTransactionRouteArgs> {
  DailyTransactionRoute({Key? key, String? date, List<PageRouteInfo>? children})
    : super(
        DailyTransactionRoute.name,
        args: DailyTransactionRouteArgs(key: key, date: date),
        rawQueryParams: {'date': date},
        initialChildren: children,
      );

  static const String name = 'DailyTransactionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<DailyTransactionRouteArgs>(
        orElse: () =>
            DailyTransactionRouteArgs(date: queryParams.optString('date')),
      );
      return DailyTransactionScreen(key: args.key, date: args.date);
    },
  );
}

class DailyTransactionRouteArgs {
  const DailyTransactionRouteArgs({this.key, this.date});

  final Key? key;

  final String? date;

  @override
  String toString() {
    return 'DailyTransactionRouteArgs{key: $key, date: $date}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DailyTransactionRouteArgs) return false;
    return key == other.key && date == other.date;
  }

  @override
  int get hashCode => key.hashCode ^ date.hashCode;
}

/// generated route for
/// [EditProfileScreen]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfileScreen();
    },
  );
}

/// generated route for
/// [ExtraMileageScreen]
class ExtraMileageRoute extends PageRouteInfo<void> {
  const ExtraMileageRoute({List<PageRouteInfo>? children})
    : super(ExtraMileageRoute.name, initialChildren: children);

  static const String name = 'ExtraMileageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ExtraMileageScreen();
    },
  );
}

/// generated route for
/// [HeadOfficeContactsPage]
class HeadOfficeContactsRoute extends PageRouteInfo<void> {
  const HeadOfficeContactsRoute({List<PageRouteInfo>? children})
    : super(HeadOfficeContactsRoute.name, initialChildren: children);

  static const String name = 'HeadOfficeContactsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HeadOfficeContactsPage();
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
/// [PaymentRequestListScreen]
class PaymentRequestListRoute extends PageRouteInfo<void> {
  const PaymentRequestListRoute({List<PageRouteInfo>? children})
    : super(PaymentRequestListRoute.name, initialChildren: children);

  static const String name = 'PaymentRequestListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PaymentRequestListScreen();
    },
  );
}

/// generated route for
/// [PaymentRequestScreen]
class PaymentRequestRoute extends PageRouteInfo<void> {
  const PaymentRequestRoute({List<PageRouteInfo>? children})
    : super(PaymentRequestRoute.name, initialChildren: children);

  static const String name = 'PaymentRequestRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PaymentRequestScreen();
    },
  );
}

/// generated route for
/// [RedirectedOrdersScreen]
class RedirectedOrdersRoute extends PageRouteInfo<void> {
  const RedirectedOrdersRoute({List<PageRouteInfo>? children})
    : super(RedirectedOrdersRoute.name, initialChildren: children);

  static const String name = 'RedirectedOrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RedirectedOrdersScreen();
    },
  );
}

/// generated route for
/// [ServiceStationScreen]
class ServiceStationRoute extends PageRouteInfo<void> {
  const ServiceStationRoute({List<PageRouteInfo>? children})
    : super(ServiceStationRoute.name, initialChildren: children);

  static const String name = 'ServiceStationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ServiceStationScreen();
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
/// [TodaysRedirectedOrdersScreen]
class TodaysRedirectedOrdersRoute extends PageRouteInfo<void> {
  const TodaysRedirectedOrdersRoute({List<PageRouteInfo>? children})
    : super(TodaysRedirectedOrdersRoute.name, initialChildren: children);

  static const String name = 'TodaysRedirectedOrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TodaysRedirectedOrdersScreen();
    },
  );
}

/// generated route for
/// [VendorInfoScreen]
class VendorInfoRoute extends PageRouteInfo<void> {
  const VendorInfoRoute({List<PageRouteInfo>? children})
    : super(VendorInfoRoute.name, initialChildren: children);

  static const String name = 'VendorInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VendorInfoScreen();
    },
  );
}

/// generated route for
/// [VendorMessagesScreen]
class VendorMessagesRoute extends PageRouteInfo<void> {
  const VendorMessagesRoute({List<PageRouteInfo>? children})
    : super(VendorMessagesRoute.name, initialChildren: children);

  static const String name = 'VendorMessagesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VendorMessagesScreen();
    },
  );
}
