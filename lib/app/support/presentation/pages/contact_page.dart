import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/theme/text_styles.dart';
import 'package:gaaubesi_vendor/core/widgets/custom_card.dart';
import 'package:gaaubesi_vendor/core/widgets/input_field.dart';
import 'package:gaaubesi_vendor/core/widgets/primary_button.dart';

@RoutePage()
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get in Touch', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'We are here to help you. Reach out to us via any of the following channels.',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 24),
            _buildContactOption(
              context,
              icon: Icons.phone,
              title: 'Call Us',
              subtitle: '+977-9800000000',
              onTap: () {},
            ),
            _buildContactOption(
              context,
              icon: Icons.email,
              title: 'Email Us',
              subtitle: 'support@gaaubesi.com',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            Text('Send us a Message', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            InputField(
              controller:
                  TextEditingController(), // TODO: Use proper controller
              label: 'Subject',
              hint: 'Enter subject',
            ),
            const SizedBox(height: 16),
            InputField(
              controller:
                  TextEditingController(), // TODO: Use proper controller
              label: 'Message',
              hint: 'Type your message here...',
              // maxLines not supported in InputField yet, defaulting to 1
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Send Message', onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
