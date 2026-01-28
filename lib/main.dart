import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/presentation/bloc/calculate_delivery_charge_bloc.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/pages/comments_page.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contact_bloc.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/list/customer_bloc.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/detail/customer_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/daily_transections/presentation/bloc/daily_transaction_bloc.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_mileage_list_bloc.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_bloc.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/bloc/vendor_message_bloc.dart';
import 'package:gaaubesi_vendor/features/notice/presentation/bloc/notice_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_bloc.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/frequently_used_methods/frequently_used_payment_method_bloc.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_bloc.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  final router = getIt<AppRouter>();

  final authBloc = getIt<AuthBloc>();
  authBloc.add(AuthCheckRequested());

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final AppRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()),
        BlocProvider<HomeBloc>.value(value: getIt<HomeBloc>()),
        BlocProvider(create: (_) => getIt<CommentsBloc>()),
        BlocProvider(create: (context) => getIt<OrderDetailBloc>()),
        BlocProvider(create: (context) => getIt<CommentsBloc>()),
        BlocProvider(create: (context) => getIt<TicketBloc>()),
        BlocProvider(create: (context) => getIt<BranchListBloc>()),
        BlocProvider(create: (context) => getIt<WarehouseOrderBloc>()),
        BlocProvider(create: (context) => getIt<CustomerListBloc>()),
        BlocProvider(create: (context) => getIt<NoticeBloc>()),
        BlocProvider(create: (context) => getIt<CodTransferBloc>()),
        BlocProvider(create: (context) => getIt<DailyTransactionBloc>()),
        BlocProvider(create: (context) => getIt<RedirectedOrdersBloc>()),
        BlocProvider(create: (context) => getIt<CalculateDeliveryChargeBloc>()),
        BlocProvider(
          create: (context) => getIt<FrequentlyUsedPaymentMethodBloc>(),
        ),
        BlocProvider(create: (context) => getIt<PaymentRequestBloc>()),
        BlocProvider(create: (context) => getIt<VendorMessageBloc>()),
        BlocProvider(create: (context) => getIt<CustomerDetailBloc>()),
        BlocProvider(create: (context) => getIt<VendorInfoBloc>()),
        BlocProvider(create: (context) => getIt<ExtraMileageBloc>()),
        BlocProvider(create: (context) => getIt<HeadOfficeContactsBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Gaaubesi Vendor',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router.config(
          navigatorObservers: () => [commentsRouteObserver],
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
