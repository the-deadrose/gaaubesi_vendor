import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contact_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contacts_events.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contacts_state.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class HeadOfficeContactsPage extends StatelessWidget {
  const HeadOfficeContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Head Office Contacts'),
        centerTitle: true,
        elevation: 2,
      ),
      body: BlocConsumer<HeadOfficeContactsBloc, HeadOfficeContactsState>(
        listener: (context, state) {
          if (state is HeadOfficeContactsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HeadOfficeContactsLoading) {
            return _buildLoadingShimmer();
          } else if (state is HeadOfficeContactsError) {
            return _buildErrorWidget(context, state.message);
          } else if (state is HeadOfficeContactsEmpty) {
            return _buildEmptyWidget(context);
          } else if (state is HeadOfficeContactsLoaded) {
            return _buildLoadedContent(context, state.headOfficeContacts);
          } else {
            return _buildInitialWidget(context);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<HeadOfficeContactsBloc>().add(
            FetchHeadOfficeContactsEvent(),
          );
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $message',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HeadOfficeContactsBloc>().add(
                        FetchHeadOfficeContactsEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No contacts available',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<HeadOfficeContactsBloc>().add(
                FetchHeadOfficeContactsEvent(),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.contact_phone_outlined,
            size: 72,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 20),
          Text(
            'Head Office Contacts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Get in touch with our head office departments and representatives',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HeadOfficeContactsBloc>().add(
                FetchHeadOfficeContactsEvent(),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Load Contacts'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    HeadOfficeContactEntity headOfficeContacts,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HeadOfficeContactsBloc>().add(
          FetchHeadOfficeContactsEvent(),
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // CSR Contacts
          if (headOfficeContacts.csrContact.isNotEmpty)
            _buildContactSectionCard(
              context: context,
              title: 'Customer Service Representatives',
              contacts: headOfficeContacts.csrContact,
              icon: Icons.support_agent,
              iconColor: Colors.blue,
            ),

          const SizedBox(height: 24),

          // Departments Contacts
          if (headOfficeContacts.departments.isNotEmpty)
            _buildDepartmentsCard(
              context: context,
              departments: headOfficeContacts.departments,
            ),

          const SizedBox(height: 24),

          // Province Contacts
          if (headOfficeContacts.provinces.isNotEmpty)
            _buildProvincesCard(
              context: context,
              provinces: headOfficeContacts.provinces,
            ),

          const SizedBox(height: 24),

          // Hub Contacts
          if (headOfficeContacts.hubContact.isNotEmpty)
            _buildContactSectionCard(
              context: context,
              title: 'Hub Contacts',
              contacts: headOfficeContacts.hubContact,
              icon: Icons.location_city,
              iconColor: Colors.orange,
            ),

          const SizedBox(height: 24),

          // Valley Contacts
          if (headOfficeContacts.valleyContact.isNotEmpty)
            _buildContactSectionCard(
              context: context,
              title: 'Valley Contacts',
              contacts: headOfficeContacts.valleyContact,
              icon: Icons.landscape,
              iconColor: Colors.green,
            ),

          const SizedBox(height: 24),

          // Issue Contacts
          if (headOfficeContacts.issueContact.isNotEmpty)
            _buildContactSectionCard(
              context: context,
              title: 'Issue Resolution Team',
              contacts: headOfficeContacts.issueContact,
              icon: Icons.engineering,
              iconColor: Colors.red,
              isEmergency: true,
            ),

          const SizedBox(height: 32),

          // Last Updated Info
          _buildLastUpdatedInfo(context),
        ],
      ),
    );
  }

  Widget _buildContactSectionCard({
    required BuildContext context,
    required String title,
    required List<ContactPersonEntity> contacts,
    required IconData icon,
    required Color iconColor,
    bool isEmergency = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isEmergency
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isEmergency ? Colors.red : iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isEmergency)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      'EMERGENCY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Contacts List
            ...contacts.map(
              (contact) => _buildContactPersonTile(
                context: context,
                contactPerson: contact,
                index: contacts.indexOf(contact),
                totalCount: contacts.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactPersonTile({
    required BuildContext context,
    required ContactPersonEntity contactPerson,
    required int index,
    required int totalCount,
  }) {
    Future<void> makePhoneCall(String phoneNumber) async {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    }

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
          title: Text(
            contactPerson.contactPerson,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            contactPerson.phoneNo,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.blue),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () => makePhoneCall(contactPerson.phoneNo),
          ),
          onTap: () => makePhoneCall(contactPerson.phoneNo),
        ),
        if (index < totalCount - 1) const Divider(height: 20),
      ],
    );
  }

  Widget _buildDepartmentsCard({
    required BuildContext context,
    required Map<String, List<ContactPersonEntity>> departments,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Departments Header
            Row(
              children: [
                const Icon(Icons.business, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Departments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${departments.length} departments',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...departments.entries.map((entry) {
              return _buildDepartmentExpansionTile(
                context: context,
                departmentName: entry.key,
                contacts: entry.value,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentExpansionTile({
    required BuildContext context,
    required String departmentName,
    required List<ContactPersonEntity> contacts,
  }) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.apartment, size: 20, color: Colors.purple),
      ),
      title: Text(
        departmentName,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${contacts.length} contact${contacts.length > 1 ? 's' : ''}',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
      trailing: const Icon(Icons.expand_more, color: Colors.purple),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            children: contacts
                .map(
                  (contact) => _buildContactPersonTile(
                    context: context,
                    contactPerson: contact,
                    index: contacts.indexOf(contact),
                    totalCount: contacts.length,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProvincesCard({
    required BuildContext context,
    required Map<String, List<ContactPersonEntity>> provinces,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provinces Header
            Row(
              children: [
                const Icon(Icons.map, color: Colors.teal, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Province Contacts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${provinces.length} provinces',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Provinces List
            ...provinces.entries.map((entry) {
              return _buildProvinceExpansionTile(
                context: context,
                provinceName: entry.key,
                contacts: entry.value,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceExpansionTile({
    required BuildContext context,
    required String provinceName,
    required List<ContactPersonEntity> contacts,
  }) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.location_on, size: 20, color: Colors.teal),
      ),
      title: Text(
        provinceName,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${contacts.length} contact${contacts.length > 1 ? 's' : ''}',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
      trailing: const Icon(Icons.expand_more, color: Colors.teal),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            children: contacts
                .map(
                  (contact) => _buildContactPersonTile(
                    context: context,
                    contactPerson: contact,
                    index: contacts.indexOf(contact),
                    totalCount: contacts.length,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLastUpdatedInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Contacts are regularly updated. Tap refresh to get latest information.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this widget function in the same HeadOfficeContactsPage class
}

Widget _buildLoadingShimmer() {
  return CustomShimmerLoading();
}

class CustomShimmerLoading extends StatefulWidget {
  const CustomShimmerLoading({super.key});

  @override
  State<CustomShimmerLoading> createState() => _CustomShimmerLoadingState();
}

class _CustomShimmerLoadingState extends State<CustomShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.grey.shade300,
      end: Colors.grey.shade100,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // CSR Contacts Shimmer
            _buildSectionShimmer(
              animationColor: _animation.value!,
              titleWidth: 200,
              contactCount: 2,
            ),
            const SizedBox(height: 24),

            // Departments Shimmer
            _buildDepartmentsShimmer(_animation.value!),
            const SizedBox(height: 24),

            // Provinces Shimmer
            _buildProvincesShimmer(_animation.value!),
            const SizedBox(height: 24),

            _buildSectionShimmer(
              animationColor: _animation.value!,
              titleWidth: 150,
              contactCount: 1,
            ),
            const SizedBox(height: 24),
            _buildSectionShimmer(
              animationColor: _animation.value!,
              titleWidth: 160,
              contactCount: 1,
            ),
            const SizedBox(height: 24),
            _buildSectionShimmer(
              animationColor: _animation.value!,
              titleWidth: 180,
              contactCount: 2,
              isEmergency: true,
            ),

            const SizedBox(height: 32),
            _buildInfoShimmer(_animation.value!),
          ],
        );
      },
    );
  }
}

Widget _buildSectionShimmer({
  required Color animationColor,
  required double titleWidth,
  required int contactCount,
  bool isEmergency = false,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: animationColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: titleWidth,
                height: 24,
                decoration: BoxDecoration(
                  color: animationColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              if (isEmergency)
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: animationColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            contactCount,
            (index) => _buildContactShimmer(animationColor),
          ),
        ],
      ),
    ),
  );
}

Widget _buildContactShimmer(Color animationColor) {
  return Column(
    children: [
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: animationColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: animationColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: animationColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: animationColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget _buildDepartmentsShimmer(Color animationColor) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: animationColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 120,
                height: 24,
                decoration: BoxDecoration(
                  color: animationColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 90,
                height: 24,
                decoration: BoxDecoration(
                  color: animationColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => _buildDepartmentTileShimmer(animationColor),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDepartmentTileShimmer(Color animationColor) {
  return Column(
    children: [
      Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: animationColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 18,
                  decoration: BoxDecoration(
                    color: animationColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: animationColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: animationColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget _buildProvincesShimmer(Color animationColor) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: animationColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 150,
                height: 24,
                decoration: BoxDecoration(
                  color: animationColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 90,
                height: 24,
                decoration: BoxDecoration(
                  color: animationColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            2,
            (index) => _buildProvinceTileShimmer(animationColor),
          ),
        ],
      ),
    ),
  );
}

Widget _buildProvinceTileShimmer(Color animationColor) {
  return Column(
    children: [
      Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: animationColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(
                    color: animationColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: animationColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: animationColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget _buildInfoShimmer(Color animationColor) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: animationColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: animationColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(
                  color: animationColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
