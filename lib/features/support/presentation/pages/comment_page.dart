import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/theme/text_styles.dart';
import 'package:gaaubesi_vendor/core/widgets/input_field.dart';
import 'package:gaaubesi_vendor/core/widgets/primary_button.dart';

@RoutePage()
class CommentPage extends StatelessWidget {
  const CommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback & Comments')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We value your feedback', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Please let us know about your experience or any suggestions for improvement.',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 24),
            InputField(
              controller:
                  TextEditingController(), 
              label: 'Topic',
              hint: 'e.g., App Performance, Feature Request',
            ),
            const SizedBox(height: 16),
            InputField(
              controller:
                  TextEditingController(), 
              label: 'Your Comment',
              hint: 'Share your thoughts...',
              // maxLines not supported
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Submit Feedback', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
