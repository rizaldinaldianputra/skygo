import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../core/dio_client.dart';
import '../config/api_config.dart';
import '../models/login_request.dart';
import '../models/register_driver_request.dart';
import '../session/session_manager.dart';
import '../core/toast_service.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final SessionManager _sessionManager = SessionManager();

  Future<void> updateFcmToken(String driverId, String fcmToken) async {
    try {
      await _dio.put(
        '/drivers/$driverId/fcm-token',
        queryParameters: {'token': fcmToken},
      );
    } catch (e) {
      // Error handled by interceptor, but we might want to log it
      print("Error updating FCM token: $e");
    }
  }

  Future<bool> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map && body['status'] == true) {
          final data = body['data'];
          if (data == null) {
            ToastService.showError("Login failed: No data received");
            return false;
          }

          final token = data['token'];
          final userId = data['id'].toString();
          final name = data['name'];

          await _sessionManager.saveSession(token, userId, name);

          // Get FCM Token from Firebase
          try {
            String? fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              print("FCM Token: $fcmToken");
              await updateFcmToken(userId, fcmToken);
              await _sessionManager.saveFcmToken(fcmToken);
            }
          } catch (e) {
            print("Error getting FCM token: $e");
          }

          return true;
        } else {
          ToastService.showError(body['message'] ?? "Login failed");
        }
      }
      return false;
    } catch (e) {
      print("Login Err: $e");
      return false;
    }
  }

  Future<bool> register(RegisterDriverRequest request) async {
    try {
      FormData formData = FormData.fromMap({
        'data': MultipartFile.fromString(
          jsonEncode(request.toJson()),
          contentType: MediaType.parse('application/json'),
        ),
        'simImage': await MultipartFile.fromFile(
          request.simImage.path,
          contentType: MediaType.parse('image/jpeg'),
        ),
        'ktpImage': await MultipartFile.fromFile(
          request.ktpImage.path,
          contentType: MediaType.parse('image/jpeg'),
        ),
        // 'photo': ... if needed
      });

      final response = await _dio.post(
        ApiConfig.registerDriverEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        ToastService.showSuccess("Registration successful");
        return true;
      }
      return false;
    } catch (e) {
      // Error handled by Interceptor
      return false;
    }
  }
}
