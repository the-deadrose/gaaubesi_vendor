import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';

class EditOrderDialog extends StatefulWidget {
  final OrderDetailEntity order;
  final Function(Map<String, dynamic>) onUpdate;

  const EditOrderDialog({
    super.key,
    required this.order,
    required this.onUpdate,
  });

  static Future<void> show(
    BuildContext context, {
    required OrderDetailEntity order,
    required Function(Map<String, dynamic>) onUpdate,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          EditOrderDialog(order: order, onUpdate: onUpdate),
    );
  }

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  late TextEditingController _receiverNameController;
  late TextEditingController _receiverPhoneController;
  late TextEditingController _altReceiverPhoneController;
  late TextEditingController _receiverAddressController;
  late TextEditingController _weightController;
  late TextEditingController _codChargeController;
  late TextEditingController _remarksController;

  String? _selectedBranch;
  String? _selectedDestinationBranch;
  String? _selectedPackageAccess;
  String? _selectedPackageType;
  String? _selectedPickupType;

  final List<String> _packageAccessOptions = ['Can Open', 'Can\'t Open'];
  final List<String> _packageTypeOptions = [
    'Document',
    'Parcel',
    'Liquid',
    'Fragile',
  ];
  final List<String> _pickupTypeOptions = ['Pickup', 'Drop Off'];

  List<BranchListEntity> _branchList = [];
  bool _isLoadingBranches = true;

  @override
  void initState() {
    super.initState();
    _receiverNameController = TextEditingController(
      text: widget.order.receiverName,
    );
    _receiverPhoneController = TextEditingController(
      text: widget.order.receiverNumber,
    );
    _altReceiverPhoneController = TextEditingController(
      text: widget.order.altReceiverNumber,
    );
    _receiverAddressController = TextEditingController(
      text: widget.order.receiverAddress,
    );
    _weightController = TextEditingController(text: widget.order.weight);
    _codChargeController = TextEditingController(text: widget.order.codCharge);
    _remarksController = TextEditingController(
      text: widget.order.orderDescription,
    );

    _selectedBranch = null;
    _selectedDestinationBranch = null;
    _selectedPackageAccess = widget.order.packageAccess;
    _selectedPackageType = 'Document';
    _selectedPickupType = widget.order.pickupType;

    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final branchBloc = context.read<BranchListBloc>();

      final currentState = branchBloc.state;
      if (currentState is BranchListLoaded) {
        setState(() {
          _branchList = currentState.branchList;
          _validateAndSetBranches();
          _isLoadingBranches = false;
        });
        return;
      }

      branchBloc.add(FetchBranchListEvent(''));

      await for (final state in branchBloc.stream) {
        if (state is BranchListLoaded) {
          if (mounted) {
            setState(() {
              _branchList = state.branchList;
              _validateAndSetBranches();
              _isLoadingBranches = false;
            });
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

  void _validateAndSetBranches() {
    final seen = <String>{};
    _branchList = _branchList
        .where(
          (b) => b.value.isNotEmpty && b.label.isNotEmpty && b.code.isNotEmpty,
        )
        .where((b) => seen.add(b.value))
        .toList();

    debugPrint('Branch list loaded: ${_branchList.length} branches');

    final sourceBranchCode = widget.order.sourceBranchCode;
    final destBranchCode = widget.order.destinationBranchCode;

    final validSourceCode = sourceBranchCode.isEmpty ? null : sourceBranchCode;
    final validDestCode = destBranchCode.isEmpty ? null : destBranchCode;

    final sourceBranch = validSourceCode != null
        ? _branchList.firstWhere(
            (b) => b.code == validSourceCode,
            orElse: () => _branchList.isNotEmpty
                ? _branchList.first
                : BranchListEntity(value: '', label: '', code: ''),
          )
        : null;
    final destBranch = validDestCode != null
        ? _branchList.firstWhere(
            (b) => b.code == validDestCode,
            orElse: () => _branchList.isNotEmpty
                ? _branchList.first
                : BranchListEntity(value: '', label: '', code: ''),
          )
        : null;

    _selectedBranch = sourceBranch?.value;
    _selectedDestinationBranch = destBranch?.value;

    debugPrint('Source branch code: $sourceBranchCode -> ID: $_selectedBranch');
    debugPrint(
      'Dest branch code: $destBranchCode -> ID: $_selectedDestinationBranch',
    );
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _altReceiverPhoneController.dispose();
    _receiverAddressController.dispose();
    _weightController.dispose();
    _codChargeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (_selectedBranch == null || _selectedDestinationBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both branches')),
      );
      return;
    }

    final data = {
      'branch': int.parse(_selectedBranch!),
      'destinationBranch': int.parse(_selectedDestinationBranch!),
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'codCharge': int.tryParse(_codChargeController.text) ?? 0,
      'packageAccess': _selectedPackageAccess ?? '',
      'packageType': _selectedPackageType ?? '',
      'remarks': _remarksController.text,
      'receiverName': _receiverNameController.text,
      'receiverPhoneNumber': _receiverPhoneController.text,
      'pickupType': _selectedPickupType ?? '',
      'altReceiverPhoneNumber': _altReceiverPhoneController.text,
      'receiverFullAddress': _receiverAddressController.text,
    };
    widget.onUpdate(data);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            if (_isLoadingBranches)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBranchDropdown(theme),
                      const SizedBox(height: 20),
                      _buildDestinationBranchDropdown(theme),
                      const SizedBox(height: 20),
                      _buildReceiverNameField(theme),
                      const SizedBox(height: 20),
                      _buildReceiverPhoneField(theme),
                      const SizedBox(height: 20),
                      _buildAltReceiverPhoneField(theme),
                      const SizedBox(height: 20),
                      _buildReceiverAddressField(theme),
                      const SizedBox(height: 20),
                      _buildWeightField(theme),
                      const SizedBox(height: 20),
                      _buildCodChargeField(theme),
                      const SizedBox(height: 20),
                      _buildPackageAccessDropdown(theme),
                      const SizedBox(height: 20),
                      _buildPackageTypeDropdown(theme),
                      const SizedBox(height: 20),
                      _buildPickupTypeDropdown(theme),
                      const SizedBox(height: 20),
                      _buildRemarksField(theme),
                    ],
                  ),
                ),
              ),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Edit Order',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Source Branch',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (BuildContext dialogContext) => _BranchSearchDialog(
                title: 'Source Branch',
                branches: _branchList,
                selectedValue: _selectedBranch,
              ),
            );

            if (result != null) {
              setState(() {
                _selectedBranch = result;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedBranch != null
                        ? _branchList
                              .firstWhere(
                                (b) => b.value == _selectedBranch,
                                orElse: () => BranchListEntity(
                                  value: _selectedBranch!,
                                  label: _selectedBranch!,
                                  code: '',
                                ),
                              )
                              .label
                        : 'Select source branch',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _selectedBranch != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationBranchDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Destination Branch',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (BuildContext dialogContext) => _BranchSearchDialog(
                title: 'Destination Branch',
                branches: _branchList,
                selectedValue: _selectedDestinationBranch,
              ),
            );

            if (result != null) {
              setState(() {
                _selectedDestinationBranch = result;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDestinationBranch != null
                        ? _branchList
                              .firstWhere(
                                (b) => b.value == _selectedDestinationBranch,
                                orElse: () => BranchListEntity(
                                  value: _selectedDestinationBranch!,
                                  label: _selectedDestinationBranch!,
                                  code: '',
                                ),
                              )
                              .label
                        : 'Select destination branch',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _selectedDestinationBranch != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiverNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Receiver Name',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _receiverNameController,
          decoration: InputDecoration(
            hintText: 'Enter receiver name',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiverPhoneField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Receiver Phone',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _receiverPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter receiver phone',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildAltReceiverPhoneField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alt. Receiver Phone',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _altReceiverPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter alternate phone',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiverAddressField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Receiver Address',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _receiverAddressController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter receiver address',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Weight (kg)',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter weight',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildCodChargeField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'COD Charge',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codChargeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter COD charge',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageAccessDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Package Access',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPackageAccess,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              hint: const Text('Select package access'),
              style: theme.textTheme.bodyLarge,
              items: _packageAccessOptions.map((access) {
                return DropdownMenuItem<String>(
                  value: access,
                  child: Text(access),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPackageAccess = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageTypeDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Package Type',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPackageType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              hint: const Text('Select package type'),
              style: theme.textTheme.bodyLarge,
              items: _packageTypeOptions.map((type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPackageType = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupTypeDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Pickup Type',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPickupType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              hint: const Text('Select pickup type'),
              style: theme.textTheme.bodyLarge,
              items: _pickupTypeOptions.map((type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPickupType = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remarks',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _remarksController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter remarks',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Update',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.5,
                ),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Branch Search Dialog Widget
class _BranchSearchDialog extends StatefulWidget {
  final String title;
  final List<BranchListEntity> branches;
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
  late List<BranchListEntity> _filteredBranches;

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
            .where(
              (branch) =>
                  branch.label.toLowerCase().contains(query.toLowerCase()) ||
                  branch.code.toLowerCase().contains(query.toLowerCase()),
            )
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
                color: theme.colorScheme.primary,
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
                  fillColor: theme.scaffoldBackgroundColor,
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
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No branches found',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
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
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            branch.code,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context, branch.value);
                          },
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
