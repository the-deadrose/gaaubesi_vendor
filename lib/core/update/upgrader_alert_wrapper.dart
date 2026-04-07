import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/update/upgrader_debug_helper.dart';
import 'package:upgrader/upgrader.dart';
import 'dart:io';

/// Wrapper widget that shows the upgrade alert after the first frame is rendered
/// This prevents the dialog from being dismissed during navigation
class UpgradeAlertWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const UpgradeAlertWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<UpgradeAlertWrapper> createState() => _UpgradeAlertWrapperState();
}

class _UpgradeAlertWrapperState extends State<UpgradeAlertWrapper> {
  @override
  void initState() {
    super.initState();
    // Check for upgrades after the first frame and a small delay
    // to ensure navigation is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _checkForUpgrade();
        }
      });
    });
  }

  void _checkForUpgrade() async {
    final upgrader = UpgraderDebugHelper.getProductionUpgrader();
    await upgrader.initialize();

    if (upgrader.shouldDisplayUpgrade() && mounted) {
      _showUpgradeDialog(upgrader);
    }
  }

  void _showUpgradeDialog(Upgrader upgrader) {
    final navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null) {
      print('⚠️ Navigator context is null, cannot show dialog');
      return;
    }

    final dialogStyle = Platform.isIOS
        ? UpgradeDialogStyle.cupertino
        : UpgradeDialogStyle.material;

    final messages = upgrader.determineMessages(navigatorContext);

    if (dialogStyle == UpgradeDialogStyle.cupertino) {
      _showCupertinoDialog(upgrader, messages);
    } else {
      _showMaterialDialog(upgrader, messages);
    }
  }

  void _showMaterialDialog(Upgrader upgrader, UpgraderMessages messages) {
    final navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null) return;

    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(
              messages.message(UpgraderMessage.title) ?? 'Update Available',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(upgrader.body(messages)),
                const SizedBox(height: 16),
                // Show current and new version
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Version:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            upgrader.currentInstalledVersion ?? 'Unknown',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'New Version:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            upgrader.currentAppStoreVersion ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (upgrader.releaseNotes != null &&
                    upgrader.releaseNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    messages.message(UpgraderMessage.releaseNotes) ??
                        'Release Notes',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(upgrader.releaseNotes!),
                ],
              ],
            ),
            actions: [
              // Only show Update button - force update!
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    upgrader.sendUserToAppStore();
                    // Don't pop - keep dialog open so user must update
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    messages.message(UpgraderMessage.buttonTitleUpdate) ??
                        'Update Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCupertinoDialog(Upgrader upgrader, UpgraderMessages messages) {
    // Similar implementation for Cupertino style
    _showMaterialDialog(upgrader, messages); // For now, use Material
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
