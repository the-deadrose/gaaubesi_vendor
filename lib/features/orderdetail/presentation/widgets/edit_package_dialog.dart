import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/widgets/dialog_ui.dart';

class EditPackageDialog extends StatefulWidget {
  final OrderDetailEntity order;
  final Function(Map<String, dynamic>) onUpdate;

  const EditPackageDialog({
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
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => EditPackageDialog(order: order, onUpdate: onUpdate),
    );
  }

  @override
  State<EditPackageDialog> createState() => _EditPackageDialogState();
}

class _EditPackageDialogState extends State<EditPackageDialog> {
  late TextEditingController _weightController;
  late TextEditingController _codChargeController;
  late TextEditingController _remarksController;

  String? _selectedPackageAccess;
  String? _selectedPackageType;

  int _sourceBranchId = 0;
  int _destinationBranchId = 0;
  bool _isLoading = true;

  final List<String> _packageAccessOptions = ['Can Open', 'Can\'t Open'];
  final List<String> _packageTypeOptions = [
    'Document',
    'Parcel',
    'Liquid',
    'Fragile',
  ];

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.order.weight);
    _codChargeController = TextEditingController(text: widget.order.codCharge);
    _remarksController = TextEditingController(
      text: widget.order.orderDescription,
    );
    _selectedPackageAccess = widget.order.packageAccess.isEmpty
        ? _packageAccessOptions.first
        : widget.order.packageAccess;
    _selectedPackageType = 'Document';
    _resolveBranches();
  }

  Future<void> _resolveBranches() async {
    try {
      final bloc = context.read<BranchListBloc>();
      final state = bloc.state;
      if (state is BranchListLoaded) {
        _applyBranches(state.branchList);
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      bloc.add(FetchBranchListEvent(''));
      await for (final s in bloc.stream) {
        if (s is BranchListLoaded) {
          if (!mounted) return;
          _applyBranches(s.branchList);
          setState(() => _isLoading = false);
          break;
        } else if (s is BranchListError) {
          if (mounted) setState(() => _isLoading = false);
          break;
        }
      }
    } catch (e) {
      debugPrint('EditPackageDialog: branch resolve error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyBranches(List<BranchListEntity> branches) {
    int resolve(String code) {
      if (code.isEmpty) return 0;
      final match = branches.firstWhere(
        (b) => b.code == code,
        orElse: () => BranchListEntity(value: '', label: '', code: ''),
      );
      return int.tryParse(match.value) ?? 0;
    }

    _sourceBranchId = resolve(widget.order.sourceBranchCode);
    _destinationBranchId = resolve(widget.order.destinationBranchCode);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _codChargeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (_sourceBranchId == 0 || _destinationBranchId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not resolve branches. Try again in a moment.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final order = widget.order;
    final data = {
      'branch': _sourceBranchId,
      'destinationBranch': _destinationBranchId,
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'codCharge': int.tryParse(_codChargeController.text) ?? 0,
      'packageAccess': _selectedPackageAccess ?? '',
      'packageType': _selectedPackageType ?? '',
      'remarks': _remarksController.text,
      'receiverName': order.receiverName,
      'receiverPhoneNumber': order.receiverNumber,
      'pickupType': order.pickupType,
      'altReceiverPhoneNumber': order.altReceiverNumber,
      'receiverFullAddress': order.receiverAddress,
    };
    widget.onUpdate(data);
    Navigator.of(context).pop();
  }

  IconData _packageTypeIcon(String value) {
    switch (value) {
      case 'Document':
        return Icons.description_outlined;
      case 'Parcel':
        return Icons.inventory_2_outlined;
      case 'Liquid':
        return Icons.water_drop_outlined;
      case 'Fragile':
        return Icons.warning_amber_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogShell(
      title: 'Edit Package',
      subtitle: 'Order #${widget.order.orderId}',
      icon: Icons.inventory_2_outlined,
      isLoading: _isLoading,
      loadingMessage: 'Preparing package details…',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _handleUpdate,
      confirmLabel: 'Save package',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogUi.sectionTitle(theme, Icons.scale_outlined, 'Measurements'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DialogUi.textField(
                  theme,
                  label: 'Weight (kg)',
                  icon: Icons.scale_outlined,
                  controller: _weightController,
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  required: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DialogUi.textField(
                  theme,
                  label: 'COD (Rs.)',
                  icon: Icons.payments_outlined,
                  controller: _codChargeController,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  required: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          DialogUi.sectionTitle(theme, Icons.category_outlined, 'Category'),
          const SizedBox(height: 12),
          DialogUi.chipGroup(
            theme,
            label: 'Package type',
            required: true,
            options: _packageTypeOptions,
            selected: _selectedPackageType,
            onChanged: (v) => setState(() => _selectedPackageType = v),
            iconFor: _packageTypeIcon,
          ),
          const SizedBox(height: 16),
          DialogUi.chipGroup(
            theme,
            label: 'Package access',
            required: true,
            options: _packageAccessOptions,
            selected: _selectedPackageAccess,
            onChanged: (v) => setState(() => _selectedPackageAccess = v),
            iconFor: (v) => v == 'Can Open'
                ? Icons.lock_open_rounded
                : Icons.lock_outline_rounded,
          ),

          const SizedBox(height: 24),
          DialogUi.sectionTitle(
            theme,
            Icons.sticky_note_2_outlined,
            'Description',
          ),
          const SizedBox(height: 12),
          DialogUi.textField(
            theme,
            label: 'Package description',
            icon: Icons.edit_note_rounded,
            controller: _remarksController,
            hint: 'What is inside the package?',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
