import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Holds the most recent foreground notification received, so the UI
/// (e.g. a banner on Home) can react to it.
final latestNotificationProvider = StateProvider<String?>((ref) => null);

/// Holds this device's current FCM token — useful to display for testing
/// (paste it into Firebase Console's "Send test message" targeting).
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getToken();
});