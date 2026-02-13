import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../session/session_manager.dart';

class NotificationService {
  FirebaseMessaging? _firebaseMessaging;
  final SessionManager _sessionManager = SessionManager();

  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permission (iOS specifically)
    await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM Token
    try {
      final token = await _firebaseMessaging?.getToken();
      if (token == null || token.isEmpty) {
        // FCM tidak tersedia (device tanpa Google Play)
        print("FCM not available, skip");
        return;
      }

      print("FCM Token: $token");
      await _sessionManager.saveFcmToken(token);
    } catch (e) {
      // Jangan crash app
      print("FCM error, skipped: $e");
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message.notification!);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'skygo_channel',
          'SkyGo Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging!.getToken();
  }
}

// Top-level function for background handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
