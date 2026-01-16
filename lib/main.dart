import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/pages/comments_page.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_bloc.dart';
import 'package:gaaubesi_vendor/features/payments/presentation/bloc/payment_request_bloc.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_bloc.dart';

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
        BlocProvider(create: (context) => getIt<PaymentRequestBloc>()),
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
