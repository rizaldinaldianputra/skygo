import 'package:dio/dio.dart';
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

  Future<bool> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        body: request.toJson(),
      );

      if (response != null) {
        String token = "";

        // Handle various response structures
        if (response is Map) {
          if (response.containsKey('token')) {
            token = response['token'];
          } else if (response.containsKey('data') &&
              response['data'] is Map &&
              response['data'].containsKey('token')) {
            token = response['data']['token'];
          }
        } else if (response is String) {
          token = response;
        }

        if (token.isNotEmpty) {
          print("DEBUG: Login Successful. Token: ${token.substring(0, 10)}...");
          // Verify if the API returns separate user info or just token
          // For now saving token using empty strings for id/name if not provided
          await _sessionManager.saveSession(token, "1", "User");
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
