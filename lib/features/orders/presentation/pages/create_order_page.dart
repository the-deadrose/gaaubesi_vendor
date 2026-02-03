import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/widgets/primary_button.dart';
import 'package:gaaubesi_vendor/core/widgets/input_field.dart';
import 'package:gaaubesi_vendor/core/widgets/custom_shimmer.dart';
import 'package:gaaubesi_vendor/features/orders/domain/enums/order_enums.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/create_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_state.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/pickup_point_entity.dart';

@RoutePage()
class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<OrderBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<BranchListBloc>(),
        ),
      ],
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
  final _remarksController = TextEditingController();

  final _receiverNameFocus = FocusNode();
  final _receiverNumberFocus = FocusNode();
  final _altReceiverNumberFocus = FocusNode();
  final _receiverAddressFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _codChargeFocus = FocusNode();
  final _referenceIdFocus = FocusNode();
  final _remarksFocus = FocusNode();

  List<OrderStatusEntity> _allBranches = [];
  List<OrderStatusEntity> _filteredBranches = [];
  List<OrderStatusEntity> _allDestBranches = [];
  List<OrderStatusEntity> _filteredDestBranches = [];
  List<PickupPointEntity> _pickupPointList = [];
  
  String? _selectedSource;
  String? _selectedDestination;
  String? _selectedPickupPoint;
  PackageAccess? _selectedPackageAccess;
  PickupType? _selectedPickupType;
  PackageType? _selectedPackageType;
  
  bool _isLoading = false;
  bool _isLoadingBranches = true;
  bool _isLoadingPickupPoints = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _loadPickupPoints();
  }

  Future<void> _loadBranches() async {
    try {
      final branchBloc = context.read<BranchListBloc>();
      
      // Check current state first
      final currentState = branchBloc.state;
      if (currentState is BranchListLoaded) {
        _updateBranches(currentState.branchList);
        return;
      }

      // If not loaded, fetch branches
      branchBloc.add(FetchBranchListEvent(''));

      // Listen to branch list state
      await for (final state in branchBloc.stream) {
        if (state is BranchListLoaded) {
          if (mounted) {
            _updateBranches(state.branchList);
          }
          break;
        } else if (state is BranchListError) {
          if (mounted) {
            setState(() {
              _isLoadingBranches = false;
            });
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('Error loading branches: $e');
      if (mounted) {
        setState(() {
          _isLoadingBranches = false;
        });
      }
    }
  }

  void _updateBranches(List<OrderStatusEntity> branches) {
    debugPrint('[CreateOrderPage] _updateBranches called with ${branches.length} branches');
    for (var i = 0; i < branches.length && i < 3; i++) {
      debugPrint('[CreateOrderPage] Branch $i BEFORE filter: value="${branches[i].value}", label="${branches[i].label}", code="${branches[i].code}"');
      debugPrint('[CreateOrderPage] Branch $i isEmpty checks: value=${branches[i].value.isEmpty}, label=${branches[i].label.isEmpty}, code=${branches[i].code.isEmpty}');
    }
    setState(() {
      // Filter out branches with empty values and remove duplicates
      final seen = <String>{};
      _allBranches = branches
          .where((b) => b.value.isNotEmpty && b.label.isNotEmpty && b.code.isNotEmpty)
          .where((b) => seen.add(b.value))
          .toList();
      debugPrint('[CreateOrderPage] AFTER filter: ${_allBranches.length} branches remain');
      for (var i = 0; i < _allBranches.length && i < 3; i++) {
        debugPrint('[CreateOrderPage] Filtered Branch $i: value="${_allBranches[i].value}", label="${_allBranches[i].label}", code="${_allBranches[i].code}"');
      }
      _filteredBranches = List.from(_allBranches);
      _allDestBranches = List.from(_allBranches);
      _filteredDestBranches = List.from(_allDestBranches);
      _isLoadingBranches = false;
    });
  }

  Future<void> _loadPickupPoints() async {
    try {
      final branchBloc = context.read<BranchListBloc>();

      // Check current state first
      final currentState = branchBloc.state;
      if (currentState is PickUpPointLoaded) {
        setState(() {
          _pickupPointList = currentState.pickupPoints
              .where((p) => p.value.isNotEmpty && p.label.isNotEmpty)
              .toList();
          _isLoadingPickupPoints = false;
        });
        return;
      }

      // If not loaded, fetch pickup points
      branchBloc.add(FetchPickupPointsEvent());

      // Listen to pickup points state
      await for (final state in branchBloc.stream) {
        if (state is PickUpPointLoaded) {
          if (mounted) {
            setState(() {
              _pickupPointList = state.pickupPoints
                  .where((p) => p.value.isNotEmpty && p.label.isNotEmpty)
                  .toList();
              _isLoadingPickupPoints = false;
            });
          }
          break;
        } else if (state is PickUpPointError) {
          if (mounted) {
            setState(() {
              _isLoadingPickupPoints = false;
            });
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('Error loading pickup points: $e');
      if (mounted) {
        setState(() {
          _isLoadingPickupPoints = false;
        });
      }
    }
  }

  void _filterSourceBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = List.from(_allBranches);
      } else {
        _filteredBranches = _allBranches
            .where((branch) =>
                branch.label.toLowerCase().contains(query.toLowerCase()) ||
                branch.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterDestinationBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDestBranches = List.from(_allDestBranches);
      } else {
        _filteredDestBranches = _allDestBranches
            .where((branch) =>
                branch.label.toLowerCase().contains(query.toLowerCase()) ||
                branch.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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
    _remarksController.dispose();

    _receiverNameFocus.dispose();
    _receiverNumberFocus.dispose();
    _altReceiverNumberFocus.dispose();
    _receiverAddressFocus.dispose();
    _weightFocus.dispose();
    _codChargeFocus.dispose();
    _referenceIdFocus.dispose();
    _remarksFocus.dispose();

    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final branchId = int.tryParse(_selectedSource ?? '');
      final destBranchId = int.tryParse(_selectedDestination ?? '');

      if (branchId == null || destBranchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid branch selection'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final request = CreateOrderRequestEntity(
        branch: branchId.toString(),
        destinationBranch: destBranchId.toString(),
        receiverName: _receiverNameController.text,
        receiverPhoneNumber: _receiverNumberController.text,
        altReceiverPhoneNumber: _altReceiverNumberController.text.isEmpty
            ? null
            : _altReceiverNumberController.text,
        receiverFullAddress: _receiverAddressController.text,
        weight: double.parse(_weightController.text),
        codCharge: double.parse(
          _codChargeController.text.isEmpty ? '0' : _codChargeController.text,
        ),
        packageAccess: _selectedPackageAccess!.displayName,
        referenceId: _referenceIdController.text.isEmpty
            ? null
            : _referenceIdController.text,
        pickupPoint: _selectedPickupPoint,
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
          context.read<OrderBloc>().add(const OrderRefreshRequested());
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
            centerTitle: true,
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
          body: (_isLoadingBranches || _isLoadingPickupPoints)
              ? _buildFullScreenShimmer()
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSectionHeader('Route Information', Icons.route),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          _buildBranchDropdownField(
                            label: 'Branch',
                            value: _selectedSource,
                            onChanged: (value) =>
                                setState(() => _selectedSource = value),
                            filteredBranches: _filteredBranches,
                            onSearchChanged: _filterSourceBranches,
                            icon: Icons.my_location,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select branch';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildBranchDropdownField(
                            label: 'Destination Branch',
                            value: _selectedDestination,
                            onChanged: (value) =>
                                setState(() => _selectedDestination = value),
                            filteredBranches: _filteredDestBranches,
                            onSearchChanged: _filterDestinationBranches,
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
                        ],
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
                        onFieldSubmitted: (_) => _codChargeFocus.requestFocus(),
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
                      _isLoadingPickupPoints
                          ? const SizedBox(
                              height: 56,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _buildPickupPointDropdownField(
                              label: 'Pickup Point (Optional)',
                              value: _selectedPickupPoint,
                              onChanged: (value) =>
                                  setState(() => _selectedPickupPoint = value),
                              icon: Icons.place_outlined,
                            ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Charges', Icons.payments),
                      const SizedBox(height: 16),
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

  Widget _buildFullScreenShimmer() {
    return CustomShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 8),
              ShimmerBox(
                width: 150,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerBox(
            height: 56,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          ShimmerBox(
            height: 56,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 8),
              ShimmerBox(
                width: 180,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (index) => Column(
              children: [
                ShimmerBox(
                  height: 56,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 8),
              ShimmerBox(
                width: 170,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Column(
              children: [
                ShimmerBox(
                  height: 56,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 8),
              ShimmerBox(
                width: 150,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            2,
            (index) => Column(
              children: [
                ShimmerBox(
                  height: 56,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 8),
              ShimmerBox(
                width: 100,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            2,
            (index) => Column(
              children: [
                ShimmerBox(
                  height: 56,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 8),
              ShimmerBox(
                width: 180,
                height: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerBox(
            height: 80,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 32),
          ShimmerBox(
            height: 50,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDropdownField({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required List<OrderStatusEntity> filteredBranches,
    required ValueChanged<String> onSearchChanged,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine which branch list to use
    final allBranches = label.contains('Destination') ? _allDestBranches : _allBranches;
    
    // Find the selected branch to display its label
    final selectedBranch = value != null
        ? allBranches.firstWhere(
            (b) => b.value == value,
            orElse: () => OrderStatusEntity(value: value, label: value, code: ''),
          )
        : null;

    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        
        // Show search dialog
        final result = await showDialog<String>(
          context: context,
          builder: (BuildContext dialogContext) => _BranchSearchDialog(
            title: label,
            branches: allBranches,
            selectedValue: value,
          ),
        );
        
        if (result != null) {
          onChanged(result);
        }
      },
      child: AbsorbPointer(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            suffixIcon: const Icon(Icons.arrow_drop_down),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha:  0.05)
                : Colors.grey.shade50,
            errorText: validator != null ? validator(value) : null,
          ),
          child: Text(
            selectedBranch?.label ?? 'Select ${label.toLowerCase()}',
            style: TextStyle(
              color: selectedBranch != null ? Colors.black : Colors.grey.shade600,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
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

  Widget _buildPickupPointDropdownField({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required IconData icon,
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
      isExpanded: true,
      items: _pickupPointList.map((PickupPointEntity pickupPoint) {
        return DropdownMenuItem<String>(
          value: pickupPoint.value,
          child: Text(
            pickupPoint.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      onTap: () => FocusScope.of(context).unfocus(),
    );
  }
}

// Search Dialog Widget
class _BranchSearchDialog extends StatefulWidget {
  final String title;
  final List<OrderStatusEntity> branches;
  final String? selectedValue;

  const _BranchSearchDialog({
    required this.title,
    required this.branches,
    this.selectedValue,
  });

  @override
  State<_BranchSearchDialog> createState() => _BranchSearchDialogState();
}

class _BranchSearchDialogState extends State<_BranchSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<OrderStatusEntity> _filteredBranches = [];

  @override
  void initState() {
    super.initState();
    _filteredBranches = widget.branches;
  }

  void _filterBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = widget.branches;
      } else {
        _filteredBranches = widget.branches
            .where((branch) =>
                branch.label.toLowerCase().contains(query.toLowerCase()) ||
                branch.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search branch...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterBranches('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: _filterBranches,
              ),
            ),
            const Divider(height: 1),
            // Branch List
            Expanded(
              child: _filteredBranches.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No branches found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredBranches.length,
                      itemBuilder: (context, index) {
                        final branch = _filteredBranches[index];
                        final isSelected = branch.value == widget.selectedValue;
                        
                        return ListTile(
                          title: Text(
                            branch.label,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            branch.code,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: theme.primaryColor)
                              : null,
                          selected: isSelected,
                          selectedTileColor: theme.primaryColor.withValues(alpha: 0.1),
                          onTap: () => Navigator.pop(context, branch.value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}