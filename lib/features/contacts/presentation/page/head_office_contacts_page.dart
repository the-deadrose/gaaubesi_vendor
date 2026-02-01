import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contact_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contacts_events.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contacts_state.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class HeadOfficeContactsPage extends StatefulWidget {
  const HeadOfficeContactsPage({super.key});

  @override
  State<HeadOfficeContactsPage> createState() => _HeadOfficeContactsPageState();
}

class _HeadOfficeContactsPageState extends State<HeadOfficeContactsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    context.read<HeadOfficeContactsBloc>().add(FetchHeadOfficeContactsEvent());
  }

  Future<void> _refreshData() async {
    context.read<HeadOfficeContactsBloc>().add(FetchHeadOfficeContactsEvent());
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Head Office Contacts'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
          return _buildContent(state);
        },
      ),
    );
  }

  Widget _buildContent(HeadOfficeContactsState state) {
    if (state is HeadOfficeContactsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HeadOfficeContactsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchInitialData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state is HeadOfficeContactsEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No contacts available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state is HeadOfficeContactsLoaded) {
      return _buildLoadedContent(state.headOfficeContacts);
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadedContent(HeadOfficeContactEntity headOfficeContacts) {
    final List<Map<String, dynamic>> sections = [];

    if (headOfficeContacts.csrContact.isNotEmpty) {
      sections.add({
        'title': 'Customer Service',
        'contacts': headOfficeContacts.csrContact,
        'icon': Icons.support_agent,
      });
    }

    if (headOfficeContacts.departments.isNotEmpty) {
      for (final entry in headOfficeContacts.departments.entries) {
        sections.add({
          'title': entry.key,
          'contacts': entry.value,
          'icon': Icons.business,
        });
      }
    }

    if (headOfficeContacts.provinces.isNotEmpty) {
      for (final entry in headOfficeContacts.provinces.entries) {
        sections.add({
          'title': entry.key,
          'contacts': entry.value,
          'icon': Icons.location_on,
        });
      }
    }

    if (headOfficeContacts.hubContact.isNotEmpty) {
      sections.add({
        'title': 'Hub Contacts',
        'contacts': headOfficeContacts.hubContact,
        'icon': Icons.location_city,
      });
    }

    if (headOfficeContacts.valleyContact.isNotEmpty) {
      sections.add({
        'title': 'Valley Contacts',
        'contacts': headOfficeContacts.valleyContact,
        'icon': Icons.landscape,
      });
    }

    if (headOfficeContacts.issueContact.isNotEmpty) {
      sections.add({
        'title': 'Issue Resolution',
        'contacts': headOfficeContacts.issueContact,
        'icon': Icons.engineering,
        'isEmergency': true,
      });
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final section = sections[index];
          return _buildSection(
            title: section['title'] as String,
            contacts: section['contacts'] as List<ContactPersonEntity>,
            icon: section['icon'] as IconData,
            isEmergency: section['isEmergency'] as bool? ?? false,
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<ContactPersonEntity> contacts,
    required IconData icon,
    bool isEmergency = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Emergency',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Contacts list
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: contacts.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              return _buildContactItem(contacts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(ContactPersonEntity contact) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(Icons.person, size: 20, color: Colors.grey.shade600),
      ),
      title: Text(contact.contactPerson, style: const TextStyle(fontSize: 15)),
      subtitle: Text(
        contact.phoneNo,
        style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
      ),
      trailing: Icon(Icons.phone_outlined, color: Colors.blue.shade700),
      onTap: () => _makePhoneCall(contact.phoneNo),
    );
  }
}
