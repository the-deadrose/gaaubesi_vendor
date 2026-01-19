import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/theme/text_styles.dart';
import 'package:gaaubesi_vendor/core/widgets/custom_card.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';

@RoutePage()
class UtilitiesPage extends StatelessWidget {
  const UtilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> utilities = [
      {'icon': Icons.support_agent, 'label': 'Tickets', 'color': Colors.indigo},
      {'icon': Icons.people, 'label': 'Customers', 'color': Colors.green},
      {
        'icon': Icons.notifications_none,
        'label': 'Notices',
        'color': Colors.brown,
      },
      {
        'icon': Icons.description_outlined,
        'label': 'COD Transfers',
        'color': Colors.brown,
      },
      {
        'icon': Icons.monetization_on,
        'label': 'Daily Transactions',
        'color': Colors.orange,
      }
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
            onTap: () {
              if (item['label'] == 'Tickets') {
                context.router.push(TicketRoute(subject: 'pending'));
              }
              if (item['label'] == 'Customers') {
                context.router.push(CustomerListRoute());
              }
              if (item['label'] == 'Notices') {
                context.router.push(NoticeListRoute());
              }
              if (item['label'] == 'COD Transfers') {
                context.router.push(CodTransferListRoute());
              }
              if (item['label'] == 'Daily Transactions') {
                context.router.push(DailyTransactionRoute());
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
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
