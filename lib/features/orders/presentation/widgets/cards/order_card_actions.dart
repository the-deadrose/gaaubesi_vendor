import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';

/// Mixin providing common actions for order cards.
/// Includes phone calling and sharing functionality.
mixin OrderCardActionsMixin<T extends StatefulWidget> on State<T> {
  /// Makes a phone call to the given number
  Future<void> makePhoneCall(String phoneNumber) async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
      return AppTheme.successGreen;
    } else if (lowerStatus.contains('cancel') ||
        lowerStatus.contains('return')) {
      return AppTheme.rojo;
    } else if (lowerStatus.contains('pending') ||
        lowerStatus.contains('hold')) {
      return AppTheme.warningYellow;
    } else if (lowerStatus.contains('process') ||
        lowerStatus.contains('transit')) {
      return AppTheme.infoBlue;
    }
    return AppTheme.powerBlue;
  }

  static bool isInTransit(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus.contains('transit') || lowerStatus.contains('process');
  }
}
