import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:ojekdriver/main.dart'; // for navigatorKey
import 'package:ojekdriver/component/order_acceptance_dialog.dart';

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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Driver Foreground Message: ${message.data}');
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
      }

      // Check if it's an order request
      // Backend sends data: { "orderId": "..." }
      // We might want a flag or just check if orderId exists
      if (message.data.containsKey('orderId')) {
        _showOrderDialog(message.data);
      }
    });
  }

  void _showOrderDialog(Map<String, dynamic> data) {
    if (navigatorKey.currentState?.context == null) return;

    showDialog(
      context: navigatorKey.currentState!.context,
      builder: (context) => OrderAcceptanceDialog(orderData: data),
    );
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Driver Background Message: ${message.messageId}");
}
