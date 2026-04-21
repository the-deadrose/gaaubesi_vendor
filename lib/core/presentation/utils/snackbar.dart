import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';

/// Shared SnackBar helpers. Replaces the ad-hoc SnackBars scattered across
/// feature pages so error, success, and info states look identical app-wide.
void showErrorSnack(BuildContext context, String message) {
  _show(
    context,
    message: message,
    icon: Icons.error_outline_rounded,
    background: Theme.of(context).colorScheme.errorContainer,
    foreground: Theme.of(context).colorScheme.onErrorContainer,
  );
}

void showFailureSnack(BuildContext context, Failure failure) {
  showErrorSnack(context, failure.userMessage);
}

void showSuccessSnack(BuildContext context, String message) {
  final scheme = Theme.of(context).colorScheme;
  _show(
    context,
    message: message,
    icon: Icons.check_circle_outline_rounded,
    background: scheme.primaryContainer,
    foreground: scheme.onPrimaryContainer,
  );
}

void _show(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Color background,
  required Color foreground,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
          ],
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
}

extension FailureUserMessage on Failure {
  /// User-facing message for a failure. Blocs and widgets should prefer this
  /// over the raw `.message` so that transport-level failures (offline/401)
  /// surface consistent copy instead of backend jargon.
  String get userMessage {
    if (this is NetworkFailure) {
      return message.isEmpty ? 'Check your internet connection' : message;
    }
    if (this is UnauthorizedFailure) {
      return message.isEmpty ? 'Please log in again' : message;
    }
    return message;
  }
}
