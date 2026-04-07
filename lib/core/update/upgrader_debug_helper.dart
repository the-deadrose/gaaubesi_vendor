import 'package:gaaubesi_vendor/core/update/app_upgrader_service.dart';
import 'package:upgrader/upgrader.dart';

/// Debug helper for testing the upgrader functionality
class UpgraderDebugHelper {
  /// Force show the upgrade dialog for testing
  static Upgrader getForceShowUpgrader() {
    return Upgrader(
      countryCode: 'NP',
      debugDisplayAlways: true, // Force display
      debugLogging: true,
      durationUntilAlertAgain: const Duration(seconds: 1),
      messages: VendorUpgraderMessages(),
    );
  }

  /// Production upgrader with proper timing
  static Upgrader getProductionUpgrader({bool debugMode = false}) {
    return Upgrader(
      countryCode: 'NP',
      debugDisplayAlways: debugMode, // Only force in debug mode
      debugLogging: debugMode,
      durationUntilAlertAgain: const Duration(days: 1),
      minAppVersion: '1.0.0',
      messages: VendorUpgraderMessages(),
    );
  }
}
