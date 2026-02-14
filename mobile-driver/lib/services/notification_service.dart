import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../session/session_manager.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SessionManager _sessionManager = SessionManager();

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null || token.isEmpty) {
        print("Driver FCM not available, skipped");
        return;
      }

      print("Driver FCM Token: $token");
      await _sessionManager.saveFcmToken(token);
    } catch (e) {
      print("Driver FCM error, skipped: $e");
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // General notification listener (non-order notifications)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Driver Foreground Message: ${message.data}');
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
      }
    });
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Driver Background Message: ${message.messageId}");
}
