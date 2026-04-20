import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/widgets/dialog_ui.dart';

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
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => EditOrderDialog(order: order, onUpdate: onUpdate),
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

  String? _selectedBranch;
  String? _selectedDestinationBranch;
  String? _selectedPickupType;

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
          if (mounted) setState(() => _isLoadingBranches = false);
          break;
        }
      }
    } catch (e) {
      debugPrint('Error loading branches: $e');
      if (mounted) setState(() => _isLoadingBranches = false);
    }
  }

  void _validateAndSetBranches() {
    final seen = <String>{};
    _branchList = _branchList
        .where((b) => b.value.isNotEmpty && b.label.isNotEmpty && b.code.isNotEmpty)
        .where((b) => seen.add(b.value))
        .toList();

    final srcCode = widget.order.sourceBranchCode;
    final dstCode = widget.order.destinationBranchCode;

    BranchListEntity? find(String code) => code.isEmpty
        ? null
        : _branchList.firstWhere(
            (b) => b.code == code,
            orElse: () => _branchList.isNotEmpty
                ? _branchList.first
                : BranchListEntity(value: '', label: '', code: ''),
          );

    _selectedBranch = find(srcCode)?.value;
    _selectedDestinationBranch = find(dstCode)?.value;
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _altReceiverPhoneController.dispose();
    _receiverAddressController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (_selectedBranch == null || _selectedDestinationBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both branches'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final order = widget.order;
    final data = {
      'branch': int.parse(_selectedBranch!),
      'destinationBranch': int.parse(_selectedDestinationBranch!),
      'weight': double.tryParse(order.weight) ?? 0.0,
      'codCharge': int.tryParse(order.codCharge) ?? 0,
      'packageAccess': order.packageAccess,
      'packageType': 'Document',
      'remarks': order.orderDescription,
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

    return DialogShell(
      title: 'Edit Order',
      subtitle: 'Order #${widget.order.orderId}',
      icon: Icons.edit_outlined,
      isLoading: _isLoadingBranches,
      loadingMessage: 'Loading branches…',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _handleUpdate,
      confirmLabel: 'Update order',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogUi.sectionTitle(theme, Icons.route_rounded, 'Route'),
          const SizedBox(height: 12),
          DialogUi.branchSelector(
            theme,
            label: 'From',
            icon: Icons.trip_origin_rounded,
            value: _selectedBranch,
            branchList: _branchList,
            hint: 'Select source branch',
            required: true,
            onTap: () => _openBranchPicker(isSource: true),
          ),
          const SizedBox(height: 10),
          DialogUi.branchSelector(
            theme,
            label: 'To',
            icon: Icons.place_rounded,
            value: _selectedDestinationBranch,
            branchList: _branchList,
            hint: 'Select destination branch',
            required: true,
            onTap: () => _openBranchPicker(isSource: false),
          ),

          const SizedBox(height: 24),
          DialogUi.sectionTitle(theme, Icons.person_rounded, 'Receiver'),
          const SizedBox(height: 12),
          DialogUi.textField(
            theme,
            label: 'Full name',
            icon: Icons.badge_outlined,
            controller: _receiverNameController,
            hint: 'Enter receiver name',
            required: true,
          ),
          const SizedBox(height: 12),
          DialogUi.textField(
            theme,
            label: 'Phone number',
            icon: Icons.call_outlined,
            controller: _receiverPhoneController,
            hint: '98xxxxxxxx',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            required: true,
          ),
          const SizedBox(height: 12),
          DialogUi.textField(
            theme,
            label: 'Alternate phone',
            icon: Icons.phone_in_talk_outlined,
            controller: _altReceiverPhoneController,
            hint: 'Optional',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          DialogUi.textField(
            theme,
            label: 'Delivery address',
            icon: Icons.location_on_outlined,
            controller: _receiverAddressController,
            hint: 'Full address with landmarks',
            maxLines: 3,
            required: true,
          ),

          const SizedBox(height: 24),
          DialogUi.sectionTitle(
            theme,
            Icons.local_shipping_outlined,
            'Pickup',
          ),
          const SizedBox(height: 12),
          DialogUi.chipGroup(
            theme,
            label: 'Pickup type',
            required: true,
            options: _pickupTypeOptions,
            selected: _selectedPickupType,
            onChanged: (v) => setState(() => _selectedPickupType = v),
            iconFor: (v) => v == 'Pickup'
                ? Icons.store_mall_directory_outlined
                : Icons.local_shipping_outlined,
          ),
        ],
      ),
    );
  }

  Future<void> _openBranchPicker({required bool isSource}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => BranchSearchDialog(
        title: isSource ? 'Source Branch' : 'Destination Branch',
        branches: _branchList,
        selectedValue: isSource ? _selectedBranch : _selectedDestinationBranch,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        if (isSource) {
          _selectedBranch = result;
        } else {
          _selectedDestinationBranch = result;
        }
      });
    }
  }
}
