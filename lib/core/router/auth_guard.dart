import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authBloc = getIt<AuthBloc>();
    final isAuthenticated = authBloc.state is AuthAuthenticated;

    if (isAuthenticated) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(const LoginRoute());
    }
  }
}
