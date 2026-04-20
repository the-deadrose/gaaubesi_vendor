import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';

/// Full-screen/centered error state used by feature pages.
///
/// Pass a [Failure] to render a type-aware icon and label; otherwise pass
/// a plain [message]. Supply [onRetry] to expose a retry button.
class ErrorView extends StatelessWidget {
  final Failure? failure;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.failure,
    this.message,
    this.onRetry,
  }) : assert(failure != null || message != null,
            'ErrorView requires either a failure or message');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final icon = _iconFor(failure);
    final title = _titleFor(failure);
    final body = message ?? failure?.message ?? 'Something went wrong';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: scheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(Failure? f) {
    if (f is NetworkFailure) return Icons.wifi_off_rounded;
    if (f is UnauthorizedFailure) return Icons.lock_outline_rounded;
    if (f is ValidationFailure) return Icons.rule_rounded;
    return Icons.error_outline_rounded;
  }

  String _titleFor(Failure? f) {
    if (f is NetworkFailure) return 'You appear to be offline';
    if (f is UnauthorizedFailure) return 'Session expired';
    if (f is ValidationFailure) return 'Please fix the highlighted fields';
    return 'Something went wrong';
  }
}
