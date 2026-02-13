import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/login_request.dart';
import '../models/register_user_request.dart';
import '../session/session_manager.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  final SessionManager _sessionManager = SessionManager();
  final ApiService _apiService = ApiService();
  final String loginEndpoint = "/auth/login";
  final String registerUserEndpoint = "/auth/user/register";
  final String userProfileEndpoint = "/users/profile";

  Future<void> updateFcmToken(String userId, String fcmToken) async {
    try {
      // Assuming existing endpoint can handle user FCM updates or similar
      // The backend code suggested FcmService is generic, but controllers might differ.
      // Driver has specific endpoint. User might need one too.
      // Based on typical patterns, users might use /users/{id}/fcm-token or similar.
      // I will use a safe guess based on driver implementation but target users
      await _apiService.put(
        '/users/$userId/fcm-token',
        queryParameters: {'token': fcmToken},
      );
    } catch (e) {
      print("Error updating User FCM token: $e");
    }
  }

  Future<bool> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        body: request.toJson(),
      );

      if (response != null) {
        String token = "";
        String userId = "1"; // Default or extracted

        // Handle various response structures
        if (response is Map) {
          if (response.containsKey('token')) {
            token = response['token'];
          } else if (response.containsKey('data') &&
              response['data'] is Map &&
              response['data'].containsKey('token')) {
            token = response['data']['token'];
            if (response['data'].containsKey('id')) {
              userId = response['data']['id'].toString();
            }
          }
        } else if (response is String) {
          token = response;
        }

        if (token.isNotEmpty) {
          print("DEBUG: Login Successful. Token: ${token.substring(0, 10)}...");

          await _sessionManager.saveSession(token, userId, "User");

          // Get FCM Token
          try {
            String? fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              print("User FCM Token: $fcmToken");
              await updateFcmToken(userId, fcmToken);
            }
          } catch (e) {
            print("Error getting User FCM token: $e");
          }

          return true;
        } else {
          print("DEBUG: Login Failed. Token is empty. Response: $response");
        }
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  Future<bool> register(RegisterUserRequest request) async {
    try {
      final response = await _apiService.post(
        registerUserEndpoint,
        body: request.toJson(),
      );
      return response != null;
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }

  Future<bool> syncUser(String token) async {
    try {
      // Use Dio Options for custom headers
      final response = await _apiService.post(
        '/auth/google-sync', // Assuming this endpoint exists and handling baseUrl from ApiService
        // If baseUrl includes /api, and this is relative.
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response != null &&
          response is Map &&
          response.containsKey('token')) {
        await _sessionManager.saveSession(
          response['token'],
          "1",
          "Google User",
        );
        return true;
      }
      return false;
    } catch (e) {
      print("Sync error: $e");
      return false;
    }
  }
}
