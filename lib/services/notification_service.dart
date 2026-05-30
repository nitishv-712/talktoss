import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        '[NotificationService] User granted permission: ${settings.authorizationStatus}',
      );

      // Foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          '[NotificationService] Got a message whilst in the foreground!',
        );
        debugPrint('[NotificationService] Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
            '[NotificationService] Message also contained a notification: ${message.notification?.title}',
          );
        }
      });

      // Token refresh listener
      _messaging.onTokenRefresh
          .listen((fcmToken) {
            debugPrint('[NotificationService] FCM Token Refreshed: $fcmToken');
            AuthService.updateFcmToken(fcmToken);
          })
          .onError((err) {
            debugPrint('[NotificationService] Error getting token: $err');
          });

      // Sync initial token if logged in
      final initialToken = await _messaging.getToken();
      if (initialToken != null) {
        await AuthService.updateFcmToken(initialToken);
      }
    } catch (e) {
      debugPrint('[NotificationService] Error initializing: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[NotificationService] Failed to get FCM token: $e');
      return null;
    }
  }
}
