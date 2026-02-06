import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffListBloc>().add(FetchStaffListEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      appBar: AppBar(
        backgroundColor: AppTheme.marianBlue,
        foregroundColor: AppTheme.whiteSmoke,
        title: const Text('Staff Management'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.router.push(const CreateStaffRoute());
            },
            icon: const Icon(Icons.person_add),
            tooltip: 'Add New Staff',
          ),
        ],
      ),
      body: BlocBuilder<StaffListBloc, StaffListState>(
        builder: (context, state) {
          return _buildContentBasedOnState(state);
        },
      ),
    );
  }

  Widget _buildContentBasedOnState(StaffListState state) {
    if (state is StaffListInitial) {
      return _buildInitialView();
    } else if (state is StaffListLoading) {
      return _buildShimmerLoading();
    } else if (state is StaffListLoaded) {
      return _buildLoadedView(state);
    } else if (state is StaffListEmpty) {
      return _buildEmptyView();
    } else if (state is StaffListError) {
      return _buildErrorView(state.message);
    }
    return Container();
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 80,
              color: AppTheme.powerBlue.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Staff List...',
              style: TextStyle(fontSize: 16, color: AppTheme.darkGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 150,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedView(StaffListLoaded state) {
    final staffList = state.staffListEntity.data;
    final staffCount = staffList.length;

    return Column(
      children: [
        _buildStatsHeader(staffCount),
        const SizedBox(height: 8),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<StaffListBloc>().add(RefreshStaffListEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return _buildStaffCard(staff);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(int staffCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.marianBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.group, size: 24, color: AppTheme.marianBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Staff',
                  style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
                ),
                Text(
                  '$staffCount',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.marianBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$staffCount member${staffCount != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffEntity staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.powerBlue.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.marianBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.marianBlue.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            staff.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.marianBlue.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildInfoRow(
                icon: Icons.person_outline,
                label: 'Username',
                value: staff.username,
              ),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: staff.email,
              ),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: staff.phoneNumber,
              ),

              const SizedBox(height: 12),

              _buildActionButtons(staff),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.darkGray),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: AppTheme.darkGray),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(StaffEntity staff) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.router.push(StaffInfoEditRoute(staff: staff));
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: AppTheme.marianBlue),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.router.push(
                ChangeStaffPasswordRoute(userId: staff.id.toString()),
              );
            },
            icon: const Icon(Icons.lock, size: 16),
            label: const Text('Password'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: AppTheme.marianBlue),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.router.push(
                StaffEditPermissionRoute(staffId: staff.id.toString()),
              );
            },
            icon: const Icon(Icons.security, size: 16),
            label: const Text('Permissions'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: AppTheme.marianBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StaffListBloc>().add(RefreshStaffListEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    size: 80,
                    color: AppTheme.powerBlue.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Staff Members Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blackBean,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add new staff members to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.router.push(const CreateStaffRoute());
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add First Staff Member'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.marianBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppTheme.rojo),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Staff List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.rojo,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StaffListBloc>().add(FetchStaffListEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.marianBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    context.router.push(const CreateStaffRoute());
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Staff'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.marianBlue,
                    side: BorderSide(color: AppTheme.marianBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
