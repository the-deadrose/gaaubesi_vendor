import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaaubesi_vendor/features/navigation/presentation/widgets/app_drawer.dart';

@RoutePage()
class MainScaffoldPage extends StatelessWidget {
  const MainScaffoldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.router.replaceAll([const LoginRoute()]);
        }
      },
      child: AutoTabsRouter(
        routes:  [const HomeRoute(), OrdersRoute()],
        builder: (context, child) {
          AutoTabsRouter.of(context);

          return Scaffold(drawer: const AppDrawer(), body: child);
        },
      ),
    );
  }

}
