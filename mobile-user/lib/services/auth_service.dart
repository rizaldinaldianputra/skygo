import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/login_request.dart';
import '../models/register_user_request.dart';
import '../session/session_manager.dart';

class AuthService {
  final SessionManager _sessionManager = SessionManager();

  Future<bool> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming response structure similar to driver
        // If it's a raw string or complicated object, need to adjust.
        // For now, robustly handling potential token field.
        String token = "";
        if (data is Map && data.containsKey('token')) {
          token = data['token'];
        } else if (data is String) {
          // Maybe just returns token string?
          // based on AuthController it returns 'Object response', dependent on implementation.
          // Let's assume standard JSON with token.
        }

        await _sessionManager.saveSession(token, "", "");
        return true;
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  Future<bool> register(RegisterUserRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUserEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }
}
