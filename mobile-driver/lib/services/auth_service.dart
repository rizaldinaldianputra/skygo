import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/login_request.dart';
import '../models/register_driver_request.dart';
import '../models/driver_model.dart';
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
        final token =
            data['token']; // Adjust based on actual response structure
        // Assuming response might contain user info or we fetch it later
        // For now, let's assume we get a token and maybe 'id' and 'name'
        // If not, we might need a profile call.
        // Let's safe save minimal info for now or just token.

        // Simple case: response is just { "token": "..." } or similar
        // Adjusting logic: if successful, fetch profile or parse JWT.
        // For this task, assuming basic token storage.

        // If the backend returns full user object:
        // final driver = Driver.fromJson(data['user']);

        await _sessionManager.saveSession(token, "", "");
        return true;
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  Future<bool> register(RegisterDriverRequest request) async {
    try {
      var uri = Uri.parse(ApiConfig.registerDriverEndpoint);
      var multipartRequest = http.MultipartRequest('POST', uri);

      // Add JSON data
      multipartRequest.files.add(
        http.MultipartFile.fromString(
          'data',
          jsonEncode(request.toJson()),
          contentType: MediaType('application', 'json'),
        ),
      );

      // Add Files
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'ktpImage',
          request.ktpImage.path,
          contentType: MediaType('image', 'jpeg'), // robust guess
        ),
      );
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'simImage',
          request.simImage.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await multipartRequest.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Register failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }
}
