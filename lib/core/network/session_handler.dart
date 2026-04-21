/// Callback-shaped seam that lets the network layer signal a session loss
/// without depending on the presentation layer.
///
/// Implementations live under `lib/features/auth/` and fan out to AuthBloc,
/// secure storage, navigation, etc.
abstract class SessionHandler {
  Future<void> onUnauthorized();
}
