import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_list_entity.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_list/staff_list_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_list/staff_list_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/staff_list/staff_list_state.dart';

@RoutePage()
class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffListBloc>().add(FetchStaffListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [IconButton(onPressed: () {
          context.router.push(const CreateStaffRoute());
        }, icon: const Icon(Icons.add))],
      ),
      body: BlocBuilder<StaffListBloc, StaffListState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StaffListState state) {
    if (state is StaffListInitial) {
      return _buildInitialState();
    } else if (state is StaffListLoading) {
      return _buildLoadingState();
    } else if (state is StaffListLoaded) {
      return _buildLoadedState(context, state);
    } else if (state is StaffListError) {
      return _buildErrorState(context, state);
    } else if (state is StaffListEmpty) {
      return _buildEmptyState(context);
    } else {
      return Container();
    }
  }

  Widget _buildInitialState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadedState(BuildContext context, StaffListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StaffListBloc>().add(RefreshStaffListEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.staffListEntity.data.length,
        itemBuilder: (context, index) {
          final staff = state.staffListEntity.data[index];
          return _buildStaffCard(context, staff);
        },
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffEntity staff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    staff.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    staff.role,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getRoleColor(staff.role),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, staff.username),
            _buildInfoRow(Icons.email, staff.email),
            _buildInfoRow(Icons.phone, staff.phoneNumber),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Edit Info'),
                  onPressed: () {
                     context.router.push(StaffInfoEditRoute(staff: staff));
                  },
                ),
                ActionChip(
                  label: const Text('Change Password'),
                  onPressed: () {
                      context.router.push(ChangeStaffPasswordRoute(userId: staff.id.toString()));
                  },
                ),
                ActionChip(
                  label: const Text('Change Permission'),
                  onPressed: () {
                    context.router.push(StaffEditPermissionRoute(
                      staffId: staff.id.toString(),
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.blue;
      case 'supervisor':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildErrorState(BuildContext context, StaffListError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<StaffListBloc>().add(FetchStaffListEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StaffListBloc>().add(RefreshStaffListEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No staff members found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add new staff members to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
