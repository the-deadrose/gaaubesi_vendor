import 'package:upgrader/upgrader.dart';

/// Service for managing app updates using the Upgrader package.
///
/// This service provides platform-specific configuration for iOS and Android,
/// including custom messages and update policies.
///
/// The upgrader package automatically detects the app ID from:
/// - Android: package name from build.gradle (com.onepasal.gbl_ecommerse_app)
/// - iOS: bundle identifier from Xcode project (com.onepasal.customer)
///
/// Usage:
/// ```dart
/// final upgrader = AppUpgraderService.getUpgrader();
/// UpgradeAlert(upgrader: upgrader, child: child);
/// ```
class AppUpgraderService {
  /// Returns a configured Upgrader instance with platform-specific settings
  static Upgrader getUpgrader({bool debugMode = false}) {
    return Upgrader(
      // Country code for iOS App Store lookup (Nepal)
      countryCode: 'NP',

      // Check for updates daily
      durationUntilAlertAgain: const Duration(days: 1),

      // Debug settings - set to true only for testing
      debugDisplayAlways: debugMode,
      debugLogging: debugMode,

      // Minimum app version requirement
      // Users below this version will be forced to update
      minAppVersion: '1.0.0',

      // Custom messages for update dialog
      messages: VendorUpgraderMessages(languageCode: 'en'),
    );
  }

  /// Returns an Upgrader configured for force updates
  /// This will not allow users to ignore or delay the update
  static Upgrader getForceUpdateUpgrader({bool debugMode = false}) {
    return Upgrader(
      countryCode: 'NP',
      durationUntilAlertAgain: const Duration(hours: 1),
      debugDisplayAlways: debugMode,
      debugLogging: debugMode,
      minAppVersion: '1.0.0',

      messages: VendorUpgraderMessages(forceUpdate: true, languageCode: 'en'),
    );
  }

  /// Checks if an update is available without showing a dialog
  /// Useful for custom UI implementations
  static Future<bool> checkForUpdates() async {
    final upgrader = getUpgrader();
    await upgrader.initialize();
    return upgrader.isUpdateAvailable();
  }

  /// Returns the current app version
  static Future<String> getCurrentVersion() async {
    final upgrader = getUpgrader();
    await upgrader.initialize();
    return upgrader.currentInstalledVersion ?? 'Unknown';
  }

  /// Returns the latest version available in the store
  static Future<String> getLatestVersion() async {
    final upgrader = getUpgrader();
    await upgrader.initialize();
    return upgrader.currentAppStoreVersion ?? 'Unknown';
  }
}

/// Custom messages for OnePasal upgrade prompts
class VendorUpgraderMessages extends UpgraderMessages {
  final bool forceUpdate;

  VendorUpgraderMessages({this.forceUpdate = false, String? languageCode})
    : super(code: languageCode ?? 'en');

  @override
  String? message(UpgraderMessage messageKey) {
    if (languageCode == 'en') {
      switch (messageKey) {
        case UpgraderMessage.body:
          return forceUpdate
              ? 'This version of {{appName}} is no longer supported. Please update to the latest version to continue using the app.'
              : 'A new version of {{appName}} is available! Please update to continue enjoying the best shopping experience with new features and improvements.';
        case UpgraderMessage.buttonTitleIgnore:
          return 'Not Now';
        case UpgraderMessage.buttonTitleLater:
          return 'Remind Me Later';
        case UpgraderMessage.buttonTitleUpdate:
          return 'Update Now';
        case UpgraderMessage.prompt:
          return forceUpdate
              ? 'Update required to continue'
              : 'Would you like to update?';
        case UpgraderMessage.releaseNotes:
          return 'What\'s New';
        case UpgraderMessage.title:
          return forceUpdate ? 'Update Required' : 'Update Available';
      }
    }
    // Use default messages for other cases
    return super.message(messageKey);
  }
}
