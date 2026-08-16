import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

/// Wraps Firebase Cloud Messaging setup: permission requests, token
/// retrieval, and foreground/background message handling.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _vapidKey =
      'BPHC-EJ8gQ4cNnTukVo_hlhqiAuBJyP2zb--s-JT-gXVAALpx_uOi1FRuLF_isdcaQNkERhKqOkX8pfcxCJ537c';

  Future<void> initialize({
    required void Function(RemoteMessage message) onForegroundMessage,
  }) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission status: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen(onForegroundMessage);
  }

  Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        return await _messaging.getToken(vapidKey: _vapidKey);
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }
}