import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/app/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/app/auth/presentation/bloc/auth_event.dart';
import 'package:gaaubesi_vendor/app/auth/presentation/bloc/auth_state.dart';
import 'package:gaaubesi_vendor/core/widgets/input_field.dart';
import 'package:gaaubesi_vendor/core/widgets/primary_button.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final currentState = context.read<AuthBloc>().state;
    // Prevent multiple login attempts if already loading or authenticated
    if (currentState is AuthLoading || currentState is AuthAuthenticated) {
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          // Only listen to state changes while on login page
          return current is AuthFailure || 
                 (current is AuthAuthenticated && previous is AuthLoading);
        },
        listener: (context, state) {
          print('🔔 Auth State Changed: ${state.runtimeType}');
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is AuthAuthenticated) {
            print('✅ Navigating to home screen...');
            // Navigate to home after successful authentication
            context.router.pushAndPopUntil(
              const MainScaffoldRoute(
                children: [HomeRoute()],
              ),
              predicate: (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Container(
              color: Theme.of(context).colorScheme.primary,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.width > 600 ? 450 : double.infinity,
                          ),
                          child: Card(
                            elevation: 12,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Logo/Icon
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.storefront_rounded,
                                          size: 56,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Title
                                      Text(
                                        'Welcome Back',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              letterSpacing: -0.5,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),

                                      // Subtitle
                                      Text(
                                        'Sign in to continue to Gaaubesi Vendor',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                              height: 1.5,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 48),

                                      // Username Field
                                      InputField(
                                        controller: _usernameController,
                                        label: 'Username',
                                        hint: 'Enter your username',
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        keyboardType: TextInputType.text,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your username';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),

                                      // Password Field
                                      InputField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        hint: 'Enter your password',
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          if (value.length < 4) {
                                            return 'Password must be at least 4 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 40),

                                      // Login Button
                                      PrimaryButton(
                                        text: 'Sign In',
                                        onPressed: _onLoginPressed,
                                        isLoading: state is AuthLoading,
                                      ),

                                      const SizedBox(height: 24),

                                      // Footer
                                      Text(
                                        'By signing in, you agree to our Terms & Privacy Policy',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
