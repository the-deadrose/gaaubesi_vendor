import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_general_permission/staff_general_permission_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_general_permission/staff_general_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_order_permission/staff_order_permission_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_order_permission/staff_order_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_extra_mileage_permission/staff_extra_mileage_permission_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_extra_mileage_permission/staff_extra_mileage_permission_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/widgets/general_permission_section_widget.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/widgets/order_permission_section_widget.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/widgets/extra_mileage_permission_section_widget.dart';

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
  late Map<String, Set<int>> selectedPermissionsByType = {
    'general': {},
    'order': {},
    'extra_mileage': {},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Permissions'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GeneralPermissionSectionWidget(
              title: 'General Permissions',
              staffId: widget.staffId,
              selectedPermissions: selectedPermissionsByType['general'] ?? {},
              onTogglePermission: (permissionId) {
                setState(() {
                  if (selectedPermissionsByType['general']!
                      .contains(permissionId)) {
                    selectedPermissionsByType['general']!.remove(permissionId);
                  } else {
                    selectedPermissionsByType['general']!.add(permissionId);
                  }
                });
              },
              onSave: () {
                final selectedIds =
                    selectedPermissionsByType['general']?.toList() ?? [];

                if (selectedIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least one permission'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                context.read<StaffGeneralPermissionBloc>().add(
                      UpdateGeneralPermissions(
                        userId: widget.staffId,
                        permissionIds: selectedIds,
                      ),
                    );
              },
            ),
            const SizedBox(height: 24),

            // Order Permissions Section
            OrderPermissionSectionWidget(
              title: 'Order Actions',
              staffId: widget.staffId,
              selectedPermissions: selectedPermissionsByType['order'] ?? {},
              onTogglePermission: (permissionId) {
                setState(() {
                  if (selectedPermissionsByType['order']!
                      .contains(permissionId)) {
                    selectedPermissionsByType['order']!.remove(permissionId);
                  } else {
                    selectedPermissionsByType['order']!.add(permissionId);
                  }
                });
              },
              onSave: () {
                final selectedIds =
                    selectedPermissionsByType['order']?.toList() ?? [];

                if (selectedIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least one permission'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                context.read<StaffOrderPermissionBloc>().add(
                      UpdateOrderPermissions(
                        userId: widget.staffId,
                        permissionIds: selectedIds,
                      ),
                    );
              },
            ),
            const SizedBox(height: 24),

            // Extra Mileage Permissions Section
            ExtraMileagePermissionSectionWidget(
              title: 'Extra Mileage Permissions',
              staffId: widget.staffId,
              selectedPermissions:
                  selectedPermissionsByType['extra_mileage'] ?? {},
              onTogglePermission: (permissionId) {
                setState(() {
                  if (selectedPermissionsByType['extra_mileage']!
                      .contains(permissionId)) {
                    selectedPermissionsByType['extra_mileage']!
                        .remove(permissionId);
                  } else {
                    selectedPermissionsByType['extra_mileage']!
                        .add(permissionId);
                  }
                });
              },
              onSave: () {
                final selectedIds =
                    selectedPermissionsByType['extra_mileage']?.toList() ?? [];

                if (selectedIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least one permission'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                context.read<StaffExtraMileagePermissionBloc>().add(
                      UpdateExtraMileagePermissions(
                        userId: widget.staffId,
                        permissionIds: selectedIds,
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
