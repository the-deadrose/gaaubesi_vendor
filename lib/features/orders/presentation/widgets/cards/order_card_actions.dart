import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mixin providing common actions for order cards.
/// Includes phone calling, map opening, and sharing functionality.
mixin OrderCardActionsMixin<T extends StatefulWidget> on State<T> {
  /// Makes a phone call to the given number
  Future<void> makePhoneCall(String phoneNumber) async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Opens Google Maps with the given address
  Future<void> openMaps(String address) async {
    HapticFeedback.mediumImpact();
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Shows a share snackbar (placeholder for actual share implementation)
  void shareOrder(String orderId) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share $orderId'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Utility class for getting status-based colors
class OrderStatusColors {
  static Color getAccentColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('delivered') || lowerStatus.contains('success')) {
      return Colors.green;
    } else if (lowerStatus.contains('cancel') ||
        lowerStatus.contains('return')) {
      return Colors.red;
    } else if (lowerStatus.contains('pending') ||
        lowerStatus.contains('hold')) {
      return Colors.orange;
    } else if (lowerStatus.contains('process') ||
        lowerStatus.contains('transit')) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  static bool isInTransit(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus.contains('transit') || lowerStatus.contains('process');
  }
}
