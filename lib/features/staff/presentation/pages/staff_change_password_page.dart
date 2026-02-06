import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/change_password/change_staff_password_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/change_password/change_staff_password_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/change_password/change_staff_password_state.dart';

@RoutePage()
class ChangeStaffPasswordScreen extends StatefulWidget {
  final String userId;

  const ChangeStaffPasswordScreen({super.key, required this.userId});

  @override
  State<ChangeStaffPasswordScreen> createState() =>
      _ChangeStaffPasswordScreenState();
}

class _ChangeStaffPasswordScreenState extends State<ChangeStaffPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<ChangeStaffPasswordBloc, ChangeStaffPasswordState>(
        listener: (context, state) {
          if (state is ChangeStaffPasswordSuccess) {
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                // ignore: use_build_context_synchronously
                context.read<ChangeStaffPasswordBloc>().add(
                  ChangePasswordReset(),
                );
                _resetForm();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(true);
              }
            });
          } else if (state is ChangeStaffPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is ChangeStaffPasswordResetState) {
            _resetForm();
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    hintText: 'Enter new password',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hintText: 'Confirm new password',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildChangePasswordButton(state),
                  if (state is ChangeStaffPasswordLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton(ChangeStaffPasswordState state) {
    return ElevatedButton(
      onPressed: state is ChangeStaffPasswordLoading
          ? null
          : () {
              if (_formKey.currentState?.validate() ?? false) {
                context.read<ChangeStaffPasswordBloc>().add(
                  ChangePasswordSubmitted(
                    userId: widget.userId,
                    newPassword: _newPasswordController.text,
                    confirmPassword: _confirmPasswordController.text,
                  ),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: state is ChangeStaffPasswordLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }

  void _resetForm() {
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _formKey.currentState?.reset();
    setState(() {
      _obscureNewPassword = true;
      _obscureConfirmPassword = true;
    });
  }
}
