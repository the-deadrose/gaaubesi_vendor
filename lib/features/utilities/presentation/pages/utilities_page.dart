import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/theme/text_styles.dart';
import 'package:gaaubesi_vendor/core/widgets/custom_card.dart';

@RoutePage()
class UtilitiesPage extends StatelessWidget {
  const UtilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> utilities = [
      {
        'icon': Icons.calculate,
        'label': 'Rate Calculator',
        'color': Colors.blue,
      },
      {'icon': Icons.map, 'label': 'Route Planner', 'color': Colors.green},
      {'icon': Icons.history, 'label': 'History', 'color': Colors.orange},
      {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.purple},
      {
        'icon': Icons.notifications,
        'label': 'Notifications',
        'color': Colors.red,
      },
      {'icon': Icons.help, 'label': 'Help Guide', 'color': Colors.teal},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Utilities')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: utilities.length,
        itemBuilder: (context, index) {
          final item = utilities[index];
          return CustomCard(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha:  0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item['label'] as String,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
