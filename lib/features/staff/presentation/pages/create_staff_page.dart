import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/create_staff/create_staff_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/create_staff/create_staff_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/create_staff/create_staff_state.dart';

@RoutePage()
class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({super.key});

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<CreateStaffBloc>().add(
      CreateStaff(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        userName: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Staff')),
      body: BlocConsumer<CreateStaffBloc, CreateStaffState>(
        listener: (context, state) {
          if (state is CreateStaffSuccess) {
            _fullNameController.clear();
            _emailController.clear();
            _phoneController.clear();
            _usernameController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            context.read<CreateStaffBloc>().add(ResetCreateStaffState());

            _formKey.currentState!.reset();
          }

          if (state is CreateStaffFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _input(_fullNameController, 'Full Name'),
                  _input(_emailController, 'Email'),
                  _input(_phoneController, 'Phone Number'),
                  _input(_usernameController, 'Username'),
                  _input(_passwordController, 'Password', obscure: true),
                  _input(
                    _confirmPasswordController,
                    'Confirm Password',
                    obscure: true,
                  ),
                  const SizedBox(height: 20),
                  state is CreateStaffLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () => _submit(context),
                          child: const Text('Create Staff'),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
