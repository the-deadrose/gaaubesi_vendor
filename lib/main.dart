import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_bloc.dart';

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
      ],
      child: MaterialApp.router(
        title: 'Gaaubesi Vendor',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router.config(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
