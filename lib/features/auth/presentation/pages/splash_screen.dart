import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/core/update/app_upgrader_service.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // final AppUpdateService _appUpdateService = const AppUpdateService();

  // bool _checkingUpdate = true;
  // bool _forceUpdateRequired = false;
  // bool _openingStore = false;
  bool _navigationHandled = false;
  String _message = 'Checking for updates...';
  int _routeRetryCount = 0;
  static const int _maxRetries = 10;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkForMandatoryUpdate();
    // });
  }

  // Future<void> _checkForMandatoryUpdate() async {
  //   final result = await _appUpdateService.ensureLatestVersionAtStartup();

  //   if (!mounted) {
  //     return;
  //   }

  //   if (result == AppUpdateGateResult.continueApp) {
  //     setState(() {
  //       _checkingUpdate = false;
  //       _forceUpdateRequired = false;
  //       _message = 'Loading your account...';
  //     });
  //     // Give the widget tree time to rebuild and ensure dependencies are initialized
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         _routeIfAuthReady();
  //       }
  //     });
  //     return;
  //   }

  //   // For any other result (updateRequired or checkFailed), show the update screen
  //   setState(() {
  //     _checkingUpdate = false;
  //     _forceUpdateRequired = true;
  //     _message = result == AppUpdateGateResult.updateRequired
  //         ? 'A new version is required before you can continue.'
  //         : 'Unable to verify the app version. Please try again.';
  //   });
  // }

  // void _routeIfAuthReady() {
  //   if (_navigationHandled || _checkingUpdate || _forceUpdateRequired) {
  //     return;
  //   }

  //   final authState = context.read<AuthBloc>().state;
  //   if (authState is AuthAuthenticated) {
  //     _navigationHandled = true;
  //     _routeRetryCount = 0;
  //     context.router.replace(const MainScaffoldRoute());
  //   } else if (authState is AuthUnauthenticated) {
  //     _navigationHandled = true;
  //     _routeRetryCount = 0;
  //     context.router.replace(const LoginRoute());
  //   } else {
  //     if (mounted && _routeRetryCount < _maxRetries) {
  //       _routeRetryCount++;
  //       Future.delayed(const Duration(milliseconds: 100)).then((_) {
  //         if (mounted && !_navigationHandled) {
  //           _routeIfAuthReady();
  //         }
  //       });
  //     }
  //   }
  // }

  // Future<void> _openStoreOrRetry() async {
  //   if (!mounted) {
  //     return;
  //   }

  //   if (_message.startsWith('Unable to verify')) {
  //     setState(() {
  //       _checkingUpdate = true;
  //       _forceUpdateRequired = false;
  //       _message = 'Checking for updates...';
  //     });
  //     await _checkForMandatoryUpdate();
  //     return;
  //   }

  //   setState(() {
  //     _openingStore = true;
  //   });

  //   final opened = await _appUpdateService.openPlayStore();

  //   if (!mounted) {
  //     return;
  //   }

  //   setState(() {
  //     _openingStore = false;
  //   });

  //   if (!opened) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Open the Play Store to update the app.')),
  //     );
  //   }
  // }

  // Future<void> _skipUpdateCheck() async {
  //   if (!mounted) {
  //     return;
  //   }

  //   setState(() {
  //     _checkingUpdate = false;
  //     _forceUpdateRequired = false;
  //     _message = 'Loading your account...';
  //   });

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (mounted) {
  //       _routeIfAuthReady();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // if (_checkingUpdate || _forceUpdateRequired || _navigationHandled) {
        //   return;
        // }

        if (state is AuthAuthenticated) {
          _navigationHandled = true;
          context.router.replace(const MainScaffoldRoute());
        } else if (state is AuthUnauthenticated) {
          _navigationHandled = true;
          context.router.replace(const LoginRoute());
        }
      },
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child:
                  //  _forceUpdateRequired
                  //     ? _ForceUpdateView(
                  //         key: const ValueKey('force-update-view'),
                  //         message: _message,
                  //         isWorking: _openingStore,
                  //         onPrimaryAction: _openStoreOrRetry,
                  //         onSecondaryAction: _message.startsWith('Unable to verify')
                  //             ? _skipUpdateCheck
                  //             : null,
                  //         isVerificationFailure: _message.startsWith(
                  //           'Unable to verify',
                  //         ),
                  //       )
                  //     :
                  _SplashLoadingView(
                    key: const ValueKey('splash-loading-view'),
                    message: _message,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_checkingUpdate && !_forceUpdateRequired) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         _routeIfAuthReady();
  //       }
  //     });
  //   }
  // }
}

class _SplashLoadingView extends StatelessWidget {
  const _SplashLoadingView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'app-logo-loading',
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              child: SvgPicture.asset(
                'assets/gaaubesi.svg',
                height: 120,
                width: 120,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppTheme.marianBlue,
                AppTheme.marianBlue.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Gaaubesi',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seller Application',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _ForceUpdateView extends StatelessWidget {
  const _ForceUpdateView({
    super.key,
    required this.message,
    required this.isWorking,
    required this.onPrimaryAction,
    this.onSecondaryAction,
    this.isVerificationFailure = false,
  });

  final String message;
  final bool isWorking;
  final Future<void> Function() onPrimaryAction;
  final Future<void> Function()? onSecondaryAction;
  final bool isVerificationFailure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'app-logo-update',
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  child: SvgPicture.asset(
                    'assets/gaaubesi.svg',
                    height: 96,
                    width: 96,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Update required',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.blackBean,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isWorking ? null : onPrimaryAction,
                  child: isWorking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update now'),
                ),
              ),
              if (isVerificationFailure && onSecondaryAction != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onSecondaryAction,
                    child: const Text('Continue without update'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
