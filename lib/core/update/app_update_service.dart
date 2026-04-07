import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppUpdateGateResult {
	continueApp,
	updateRequired,
	checkFailed,
}

class AppUpdateService {
	const AppUpdateService();

	static const String _androidPackageName = 'com.vendor.gaaubesi';

	static final Uri _playStoreUri = Uri.parse(
		'https://play.google.com/store/apps/details?id=$_androidPackageName',
	);

	Future<AppUpdateGateResult> ensureLatestVersionAtStartup() async {
		if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
			return AppUpdateGateResult.continueApp;
		}

		try {
			final updateInfo = await InAppUpdate.checkForUpdate();

			// If no update is available at all, continue
			if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
				print('📱 No update available. UpdateAvailability: ${updateInfo.updateAvailability}');
				return AppUpdateGateResult.continueApp;
			}

			print('📱 Update is available, checking versions...');

			// Check if Play Store version is actually higher than current app version
			final packageInfo = await PackageInfo.fromPlatform();
			final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
			final playStoreVersionCode = updateInfo.availableVersionCode ?? 0;

			print('📱 Current App Version: ${packageInfo.version} (Build: $currentVersionCode)');
			print('📱 Play Store Build: $playStoreVersionCode');

			// Only proceed with update if Play Store version is higher
			if (playStoreVersionCode <= currentVersionCode) {
				print('✓ Current version is up to date. No update needed.');
				return AppUpdateGateResult.continueApp;
			}

			print('⚠️ Update available: Play Store has a newer version!');

			// An update is available and version is higher - try immediate update if allowed
			if (updateInfo.immediateUpdateAllowed) {
				print('Attempting immediate update...');
				try {
					final updateResult = await InAppUpdate.performImmediateUpdate();
					if (updateResult == AppUpdateResult.success) {
						print('✓ Immediate update completed successfully');
						return AppUpdateGateResult.continueApp;
					}
				} catch (e) {
					// Immediate update failed - continue anyway
					print('❌ Immediate update failed: $e');
					return AppUpdateGateResult.continueApp;
				}
			}

			// Update is available and version is higher, but immediate update not allowed
			// Show update required screen
			print('⚠️ Showing update required screen (Flexible/Optional update)');
			return AppUpdateGateResult.updateRequired;
		} on PlatformException catch (e) {
			// Handle app not owned by Play Store (common in debug mode)
			if (e.code == 'TASK_FAILURE' && e.message?.contains('not owned') == true) {
				print('📱 App not installed from Play Store (debug mode) - skipping update check');
				return AppUpdateGateResult.continueApp;
			}
			print('❌ Platform error checking for updates: ${e.message}');
			return AppUpdateGateResult.checkFailed;
		} catch (e) {
			print('❌ Error checking for updates: $e');
			return AppUpdateGateResult.checkFailed;
		}
	}

	Future<bool> openPlayStore() async {
		return launchUrl(
			_playStoreUri,
			mode: LaunchMode.externalApplication,
		);
	}
}
