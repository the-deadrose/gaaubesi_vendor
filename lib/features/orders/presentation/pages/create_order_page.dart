import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/widgets/primary_button.dart';
import 'package:gaaubesi_vendor/core/widgets/input_field.dart';
import 'package:gaaubesi_vendor/features/orders/domain/enums/order_enums.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/create_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_state.dart';

@RoutePage()
class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderBloc>(),
      child: const _CreateOrderView(),
    );
  }
}

class _CreateOrderView extends StatefulWidget {
  const _CreateOrderView();

  @override
  State<_CreateOrderView> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<_CreateOrderView> {
  final _formKey = GlobalKey<FormState>();
  final _receiverNameController = TextEditingController();
  final _receiverNumberController = TextEditingController();
  final _altReceiverNumberController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _weightController = TextEditingController();
  final _deliveryChargeController = TextEditingController();
  final _codChargeController = TextEditingController();
  final _referenceIdController = TextEditingController();
  final _pickupPointController = TextEditingController();
  final _remarksController = TextEditingController();

  final _receiverNameFocus = FocusNode();
  final _receiverNumberFocus = FocusNode();
  final _altReceiverNumberFocus = FocusNode();
  final _receiverAddressFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _deliveryChargeFocus = FocusNode();
  final _codChargeFocus = FocusNode();
  final _referenceIdFocus = FocusNode();
  final _pickupPointFocus = FocusNode();
  final _remarksFocus = FocusNode();

  String? _selectedSource;
  String? _selectedDestination;
  PackageAccess? _selectedPackageAccess;
  PickupType? _selectedPickupType;
  PackageType? _selectedPackageType;
  bool _isLoading = false;

  final List<String> _branches = [
    'Kathmandu',
    'Pokhara',
    'Chitwan',
    'Butwal',
    'Biratnagar',
  ];

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverNumberController.dispose();
    _altReceiverNumberController.dispose();
    _receiverAddressController.dispose();
    _weightController.dispose();
    _deliveryChargeController.dispose();
    _codChargeController.dispose();
    _referenceIdController.dispose();
    _pickupPointController.dispose();
    _remarksController.dispose();

    _receiverNameFocus.dispose();
    _receiverNumberFocus.dispose();
    _altReceiverNumberFocus.dispose();
    _receiverAddressFocus.dispose();
    _weightFocus.dispose();
    _deliveryChargeFocus.dispose();
    _codChargeFocus.dispose();
    _referenceIdFocus.dispose();
    _pickupPointFocus.dispose();
    _remarksFocus.dispose();

    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateOrderRequestEntity(
        branch: _selectedSource!,
        destinationBranch: _selectedDestination!,
        receiverName: _receiverNameController.text,
        receiverPhoneNumber: _receiverNumberController.text,
        altReceiverPhoneNumber: _altReceiverNumberController.text.isEmpty
            ? null
            : _altReceiverNumberController.text,
        receiverFullAddress: _receiverAddressController.text,
        weight: double.parse(_weightController.text),
        deliveryCharge: double.parse(_deliveryChargeController.text),
        codCharge: double.parse(
          _codChargeController.text.isEmpty ? '0' : _codChargeController.text,
        ),
        packageAccess: _selectedPackageAccess!.displayName,
        referenceId: _referenceIdController.text.isEmpty
            ? null
            : _referenceIdController.text,
        pickupPoint: _pickupPointController.text.isEmpty
            ? null
            : _pickupPointController.text,
        pickupType: _selectedPickupType!.displayName,
        packageType: _selectedPackageType!.displayName,
        remarks: _remarksController.text.isEmpty
            ? null
            : _remarksController.text,
      );

      context.read<OrderBloc>().add(OrderCreateRequested(request: request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCreating) {
          setState(() => _isLoading = true);
        } else if (state is OrderCreated) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.router.maybePop();
        } else if (state is OrderCreateFailed) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : const Color(0xFFF8F9FC),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Theme.of(context).platform == TargetPlatform.iOS
                    ? Icons.arrow_back_ios
                    : Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => context.router.maybePop(),
            ),
            title: Text(
              'Create New Order',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: theme.primaryColor,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha:  0.8),
                  ],
                ),
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Route Information', Icons.route),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Branch',
                  value: _selectedSource,
                  items: _branches,
                  onChanged: (value) => setState(() => _selectedSource = value),
                  icon: Icons.my_location,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select branch';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Destination Branch',
                  value: _selectedDestination,
                  items: _branches,
                  onChanged: (value) =>
                      setState(() => _selectedDestination = value),
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select destination branch';
                    }
                    if (value == _selectedSource) {
                      return 'Destination must be different from source';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Receiver Information', Icons.person),
                const SizedBox(height: 16),
                InputField(
                  controller: _receiverNameController,
                  label: 'Receiver Name',
                  hint: 'Enter receiver name',
                  prefixIcon: Icons.person_outline,
                  focusNode: _receiverNameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _receiverNumberFocus.requestFocus(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter receiver name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _receiverNumberController,
                  label: 'Receiver Phone Number',
                  hint: 'Enter phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  focusNode: _receiverNumberFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      _altReceiverNumberFocus.requestFocus(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _altReceiverNumberController,
                  label: 'Alternative Phone Number (Optional)',
                  hint: 'Enter alternative phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  focusNode: _altReceiverNumberFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _receiverAddressFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _receiverAddressController,
                  label: 'Receiver Full Address',
                  hint: 'Enter complete delivery address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 3,
                  focusNode: _receiverAddressFocus,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter receiver address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Package Information', Icons.inventory_2),
                const SizedBox(height: 16),
                _buildEnumDropdownField<PackageType>(
                  label: 'Package Type',
                  value: _selectedPackageType,
                  items: PackageType.values,
                  onChanged: (value) =>
                      setState(() => _selectedPackageType = value),
                  icon: Icons.category_outlined,
                  getDisplayName: (type) => type.displayName,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select package type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  hint: 'Enter package weight',
                  prefixIcon: Icons.scale_outlined,
                  keyboardType: TextInputType.number,
                  focusNode: _weightFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _referenceIdFocus.requestFocus(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter package weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildEnumDropdownField<PackageAccess>(
                  label: 'Package Access',
                  value: _selectedPackageAccess,
                  items: PackageAccess.values,
                  onChanged: (value) =>
                      setState(() => _selectedPackageAccess = value),
                  icon: Icons.lock_open_outlined,
                  getDisplayName: (access) => access.displayName,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select package access';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _referenceIdController,
                  label: 'Reference ID (Optional)',
                  hint: 'Enter reference ID',
                  prefixIcon: Icons.tag_outlined,
                  focusNode: _referenceIdFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _pickupPointFocus.requestFocus(),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Pickup & Delivery', Icons.local_shipping),
                const SizedBox(height: 16),
                _buildEnumDropdownField<PickupType>(
                  label: 'Pickup Type',
                  value: _selectedPickupType,
                  items: PickupType.values,
                  onChanged: (value) =>
                      setState(() => _selectedPickupType = value),
                  icon: Icons.delivery_dining_outlined,
                  getDisplayName: (type) => type.displayName,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select pickup type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _pickupPointController,
                  label: 'Pickup Point (Optional)',
                  hint: 'Enter pickup point',
                  prefixIcon: Icons.place_outlined,
                  focusNode: _pickupPointFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _deliveryChargeFocus.requestFocus(),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Charges', Icons.payments),
                const SizedBox(height: 16),
                InputField(
                  controller: _deliveryChargeController,
                  label: 'Delivery Charge',
                  hint: 'Enter delivery charge',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  focusNode: _deliveryChargeFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _codChargeFocus.requestFocus(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter delivery charge';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _codChargeController,
                  label: 'COD Charge',
                  hint: 'Enter COD charge (if applicable)',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  focusNode: _codChargeFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _remarksFocus.requestFocus(),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Additional Information', Icons.note),
                const SizedBox(height: 16),
                InputField(
                  controller: _remarksController,
                  label: 'Remarks (Optional)',
                  hint: 'Enter any additional remarks',
                  prefixIcon: Icons.comment_outlined,
                  maxLines: 3,
                  focusNode: _remarksFocus,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _remarksFocus.unfocus(),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Create Order',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha:  0.05)
            : Colors.grey.shade50,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      onTap: () => FocusScope.of(context).unfocus(),
    );
  }

  Widget _buildEnumDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
    required String Function(T) getDisplayName,
    String? Function(T?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha:  0.05)
            : Colors.grey.shade50,
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(getDisplayName(item)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      onTap: () => FocusScope.of(context).unfocus(),
    );
  }
}
