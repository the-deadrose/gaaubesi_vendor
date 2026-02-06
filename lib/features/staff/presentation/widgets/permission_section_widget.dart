import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_permissions_list/staff_available_permisson_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_permissions_list/staff_available_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_permissions_list/staff_available_permission_state.dart';

class PermissionSectionWidget extends StatefulWidget {
  final String title;
  final String permissionType;
  final String staffId;
  final Set<int> selectedPermissions;
  final Function(int) onTogglePermission;
  final VoidCallback onSave;

  const PermissionSectionWidget({
    super.key,
    required this.title,
    required this.permissionType,
    required this.staffId,
    required this.selectedPermissions,
    required this.onTogglePermission,
    required this.onSave,
  });

  @override
  State<PermissionSectionWidget> createState() =>
      _PermissionSectionWidgetState();
}

class _PermissionSectionWidgetState extends State<PermissionSectionWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch permissions when widget initializes
    context.read<StaffAvailablePermissionBloc>().add(
      FetchStaffAvailablePermissions(
        userId: widget.staffId,
        permissionType: widget.permissionType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            BlocBuilder<
              StaffAvailablePermissionBloc,
              StaffAvailablePermissionState
            >(
              builder: (context, state) {
                if (state is StaffAvailablePermissionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StaffAvailablePermissionError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is StaffAvailablePermissionEmpty) {
                  return const Center(child: Text('No permissions available'));
                } else if (state is StaffAvailablePermissionLoaded) {
                  // Only show this data if it matches the current permission type
                  if (state.permissionType != widget.permissionType) {
                    return const SizedBox.shrink();
                  }

                  final permissions = state.permissions.permissions;

                  if (permissions.isEmpty) {
                    return const Center(
                      child: Text('No permissions available'),
                    );
                  }

                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: permissions.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final permission = permissions[index];
                          final isAssigned = permission.isAssigned;
                          final isSelected = widget.selectedPermissions
                              .contains(permission.id);

                          return _buildPermissionTile(
                            permission: permission,
                            isAssigned: isAssigned,
                            isSelected: isSelected,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (widget.selectedPermissions.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child:
                              BlocBuilder<
                                StaffAvailablePermissionBloc,
                                StaffAvailablePermissionState
                              >(
                                builder: (context, state) {
                                  final isUpdating =
                                      state is StaffPermissionUpdating;

                                  return ElevatedButton(
                                    onPressed: isUpdating
                                        ? null
                                        : widget.onSave,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      disabledBackgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: isUpdating
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'Save Changes',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  );
                                },
                              ),
                        ),
                    ],
                  );
                }

                return const Center(child: Text('No data'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required dynamic permission,
    required bool isAssigned,
    required bool isSelected,
  }) {
    final backgroundColor = isSelected
        ? Colors.blue.withValues(alpha: 0.1)
        : (isAssigned
              ? Colors.green.withValues(alpha: 0.05)
              : Colors.transparent);

    final borderColor = isSelected
        ? Colors.blue
        : (isAssigned ? Colors.green : Colors.grey[300]);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor ?? Colors.transparent, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: _buildLeadingIcon(isAssigned, isSelected),
        title: Text(
          permission.name,
          style: TextStyle(
            fontWeight: isAssigned ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.blue
                : (isAssigned ? Colors.green[800] : Colors.black87),
          ),
        ),
        subtitle: Text(
          permission.codename,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: _buildTrailingWidget(isAssigned, isSelected),
        onTap: isAssigned
            ? null
            : () {
                widget.onTogglePermission(permission.id);
              },
      ),
    );
  }

  Widget _buildLeadingIcon(bool isAssigned, bool isSelected) {
    if (isAssigned && !isSelected) {
      // Already assigned - show checkmark
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.withValues(alpha: 0.2),
        ),
        child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
      );
    } else if (isSelected) {
      // Selected for assignment
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withValues(alpha: 0.2),
        ),
        child: const Icon(Icons.check_box, color: Colors.blue, size: 24),
      );
    } else {
      // Not assigned, not selected
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300] ?? Colors.grey),
        ),
        child: const Icon(
          Icons.check_box_outline_blank,
          color: Colors.grey,
          size: 24,
        ),
      );
    }
  }

  Widget _buildTrailingWidget(bool isAssigned, bool isSelected) {
    if (isAssigned) {
      // If already assigned, show remove button
      return Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () {
            // Handle remove permission - toggle if it's in assigned
            widget.onTogglePermission(0); // Placeholder
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission removed from queue for removal'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      );
    } else if (isSelected) {
      // If selected for addition, show badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Selected',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
