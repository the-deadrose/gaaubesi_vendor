import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_general_permission/staff_general_permission_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_general_permission/staff_general_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_general_permission/staff_general_permission_state.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_order_permission/staff_order_permission_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_order_permission/staff_order_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_order_permission/staff_order_permission_state.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_extra_mileage_permission/staff_extra_mileage_permission_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_extra_mileage_permission/staff_extra_mileage_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_extra_mileage_permission/staff_extra_mileage_permission_state.dart';

@RoutePage()
class StaffEditPermissionPage extends StatefulWidget {
  final String staffId;

  const StaffEditPermissionPage({
    super.key,
    required this.staffId,
  });

  @override
  State<StaffEditPermissionPage> createState() =>
      _StaffEditPermissionPageState();
}

class _StaffEditPermissionPageState extends State<StaffEditPermissionPage> {
  late Map<String, Set<int>> selectedPermissions = {
    'general': {},
    'order': {},
    'extra_mileage': {},
  };

  @override
  void initState() {
    super.initState();
    // Fetch permissions when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffGeneralPermissionBloc>().add(
            FetchGeneralPermissions(userId: widget.staffId),
          );
      context.read<StaffOrderPermissionBloc>().add(
            FetchOrderPermissions(userId: widget.staffId),
          );
      context.read<StaffExtraMileagePermissionBloc>().add(
            FetchExtraMileagePermissions(userId: widget.staffId),
          );
    });
  }

  void _selectAllPermissions(String type, List<int> allPermissionIds) {
    setState(() {
      selectedPermissions[type] = allPermissionIds.toSet();
    });
  }

  void _clearAllPermissions(String type) {
    setState(() {
      selectedPermissions[type] = {};
    });
  }

  void _togglePermission(String type, int permissionId) {
    setState(() {
      if (selectedPermissions[type]!.contains(permissionId)) {
        selectedPermissions[type]!.remove(permissionId);
      } else {
        selectedPermissions[type]!.add(permissionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      appBar: AppBar(
        backgroundColor: AppTheme.marianBlue,
        foregroundColor: Colors.white,
        title: const Text('Edit Permissions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save all permissions
              _saveAllPermissions();
            },
            tooltip: 'Save All',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.powerBlue.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: AppTheme.marianBlue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Staff Permissions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage access and permissions for staff member',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // General Permissions
            _buildPermissionSection(
              title: 'General Permissions',
              subtitle: 'Basic access and settings',
              icon: Icons.settings,
              type: 'general',
            ),
            const SizedBox(height: 20),

            // Order Permissions
            _buildPermissionSection(
              title: 'Order Management',
              subtitle: 'Order-related actions',
              icon: Icons.shopping_cart,
              type: 'order',
            ),
            const SizedBox(height: 20),

            // Extra Mileage Permissions
            _buildPermissionSection(
              title: 'Extra Mileage',
              subtitle: 'Mileage adjustments and approvals',
              icon: Icons.directions_car,
              type: 'extra_mileage',
            ),
            const SizedBox(height: 30),

            // Bulk Actions
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.powerBlue.withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Bulk Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _selectAllInAllSections();
                            },
                            icon: const Icon(Icons.select_all, size: 18),
                            label: const Text('Select All'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.marianBlue,
                              side: BorderSide(color: AppTheme.marianBlue),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _clearAllInAllSections();
                            },
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear All'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.rojo,
                              side: BorderSide(color: AppTheme.rojo),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _saveAllPermissions();
                },
                icon: const Icon(Icons.save, size: 20),
                label: const Text('Save All Permissions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.marianBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.powerBlue.withValues  ( alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.marianBlue.withValues  ( alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: AppTheme.marianBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                // Select/Clear buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.check_box, size: 20, color: AppTheme.marianBlue),
                      onPressed: () => _showSelectAllDialog(type),
                      tooltip: 'Select All',
                    ),
                    IconButton(
                      icon: Icon(Icons.check_box_outline_blank, size: 20, color: AppTheme.darkGray),
                      onPressed: () => _clearAllPermissions(type),
                      tooltip: 'Clear All',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Permissions List (Placeholder - you'll need to integrate with your widgets)
            if (type == 'general')
              _buildGeneralPermissions()
            else if (type == 'order')
              _buildOrderPermissions()
            else
              _buildExtraMileagePermissions(),

            const SizedBox(height: 12),

            // Section Save Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _saveSectionPermissions(type);
                },
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save This Section'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.marianBlue,
                  side: BorderSide(color: AppTheme.marianBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralPermissions() {
    return BlocBuilder<StaffGeneralPermissionBloc, StaffGeneralPermissionState>(
      builder: (context, state) {
        if (state is StaffGeneralPermissionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StaffGeneralPermissionLoaded) {
          final permissions = state.permissions.permissions;

          if (permissions.isEmpty) {
            return const Center(child: Text('No permissions available'));
          }

          return Stack(
            children: [
              Column(
                children: List.generate(
                  permissions.length,
                  (index) {
                    final permission = permissions[index];
                    final isAssigned = permission.isAssigned;
                    final isSelected = selectedPermissions['general']!.contains(permission.id);

                    return _buildPermissionItemWithStatus(
                      title: permission.name,
                      description: permission.codename,
                      type: 'general',
                      permissionId: permission.id,
                      isAssigned: isAssigned,
                      isSelected: isSelected,
                    );
                  },
                ),
              ),
              if (state is StaffGeneralPermissionUpdating)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }

        if (state is StaffGeneralPermissionUpdating) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StaffGeneralPermissionError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const Center(child: Text('No data'));
      },
    );
  }

  Widget _buildOrderPermissions() {
    return BlocBuilder<StaffOrderPermissionBloc, StaffOrderPermissionState>(
      builder: (context, state) {
        if (state is StaffOrderPermissionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StaffOrderPermissionLoaded) {
          final permissions = state.permissions.permissions;

          if (permissions.isEmpty) {
            return const Center(child: Text('No permissions available'));
          }

          return Stack(
            children: [
              Column(
                children: List.generate(
                  permissions.length,
                  (index) {
                    final permission = permissions[index];
                    final isAssigned = permission.isAssigned;
                    final isSelected = selectedPermissions['order']!.contains(permission.id);

                    return _buildPermissionItemWithStatus(
                      title: permission.name,
                      description: permission.codename,
                      type: 'order',
                      permissionId: permission.id,
                      isAssigned: isAssigned,
                      isSelected: isSelected,
                    );
                  },
                ),
              ),
              if (state is StaffOrderPermissionUpdating)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }

        if (state is StaffOrderPermissionUpdating) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StaffOrderPermissionError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const Center(child: Text('No data'));
      },
    );
  }

  Widget _buildExtraMileagePermissions() {
    return BlocBuilder<StaffExtraMileagePermissionBloc,
        StaffExtraMileagePermissionState>(
      builder: (context, state) {
        if (state is StaffExtraMileagePermissionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StaffExtraMileagePermissionLoaded) {
          final permissions = state.permissions.permissions;

          if (permissions.isEmpty) {
            return const Center(child: Text('No permissions available'));
          }

          return Stack(
            children: [
              Column(
                children: List.generate(
                  permissions.length,
                  (index) {
                    final permission = permissions[index];
                    final isAssigned = permission.isAssigned;
                    final isSelected = selectedPermissions['extra_mileage']!.contains(permission.id);

                    return _buildPermissionItemWithStatus(
                      title: permission.name,
                      description: permission.codename,
                      type: 'extra_mileage',
                      permissionId: permission.id,
                      isAssigned: isAssigned,
                      isSelected: isSelected,
                    );
                  },
                ),
              ),
              if (state is StaffExtraMileagePermissionUpdating)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }

        if (state is StaffExtraMileagePermissionUpdating) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StaffExtraMileagePermissionError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const Center(child: Text('No data'));
      },
    );
  }

  Widget _buildPermissionItemWithStatus({
    required String title,
    required String description,
    required String type,
    required int permissionId,
    required bool isAssigned,
    required bool isSelected,
  }) {
    final backgroundColor = isSelected
        ? AppTheme.marianBlue.withValues(alpha: 0.05)
        : (isAssigned ? Colors.green.withValues(alpha: 0.05) : Colors.transparent);

    final borderColor = isSelected
        ? AppTheme.marianBlue.withValues(alpha: 0.3)
        : (isAssigned ? Colors.green.withValues(alpha: 0.3) : AppTheme.lightGray);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: !isAssigned ? () => _togglePermission(type, permissionId) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                if (!isAssigned)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _togglePermission(type, permissionId),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: AppTheme.marianBlue,
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isAssigned || isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.marianBlue
                                    : (isAssigned ? Colors.green[800] : AppTheme.blackBean),
                              ),
                            ),
                          ),
                          if (isAssigned)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Assigned',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelectAllDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select All $type Permissions?'),
        content: Text('This will select all available permissions in this section.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Get all permission IDs for this type (you need to implement this)
              final allPermissionIds = [1, 2, 3]; // Replace with actual IDs
              _selectAllPermissions(type, allPermissionIds);
              Navigator.pop(context);
            },
            child: const Text('Select All'),
          ),
        ],
      ),
    );
  }

  void _selectAllInAllSections() {
    // Implement select all logic for all sections
    setState(() {
      selectedPermissions['general'] = {1, 2, 3};
      selectedPermissions['order'] = {1, 2, 3};
      selectedPermissions['extra_mileage'] = {1, 2};
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All permissions selected'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearAllInAllSections() {
    setState(() {
      selectedPermissions['general'] = {};
      selectedPermissions['order'] = {};
      selectedPermissions['extra_mileage'] = {};
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All permissions cleared'),
        backgroundColor: AppTheme.darkGray,
      ),
    );
  }

  void _saveSectionPermissions(String type) {
    final selectedIds = selectedPermissions[type]?.toList() ?? [];

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No $type permissions selected'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    switch (type) {
      case 'general':
        context.read<StaffGeneralPermissionBloc>().add(
              UpdateGeneralPermissions(
                userId: widget.staffId,
                permissionIds: selectedIds,
              ),
            );
        break;
      case 'order':
        context.read<StaffOrderPermissionBloc>().add(
              UpdateOrderPermissions(
                userId: widget.staffId,
                permissionIds: selectedIds,
              ),
            );
        break;
      case 'extra_mileage':
        context.read<StaffExtraMileagePermissionBloc>().add(
              UpdateExtraMileagePermissions(
                userId: widget.staffId,
                permissionIds: selectedIds,
              ),
            );
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type permissions saved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveAllPermissions() {
    final allPermissions = [
      ...?selectedPermissions['general'],
      ...?selectedPermissions['order'],
      ...?selectedPermissions['extra_mileage'],
    ];

    if (allPermissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No permissions selected'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save all sections
    _saveSectionPermissions('general');
    _saveSectionPermissions('order');
    _saveSectionPermissions('extra_mileage');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All permissions saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}