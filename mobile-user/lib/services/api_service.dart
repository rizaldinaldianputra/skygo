import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../session/session_manager.dart';

class ApiService {
  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  late Dio _dio;
  final SessionManager _sessionManager = SessionManager();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionManager.getToken();
          print("DEBUG: Sending Request to ${options.path}");
          if (token != null && token.isNotEmpty) {
            print(
              "DEBUG: Found Token: ${token.substring(0, 10)}...",
            ); // Log partial token
            options.headers['Authorization'] = 'Bearer $token';
            print("DEBUG: Headers: ${options.headers}");
          } else {
            print("DEBUG: No Token found in SessionManager");
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print(
            "Dio Error: ${e.message} - ${e.response?.statusCode} - ${e.response?.data}",
          );
          return handler.next(e);
        },
      ),
    );
  }

  // Helper to handle response data
  dynamic _handleResponse(Response response) {
    return response.data;
  }

  // GET
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      print('GET Error $endpoint: $e');
      rethrow;
    }
  }

  // POST
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } catch (e) {
      print('POST Error $endpoint: $e');
      rethrow;
    }
  }

  // PUT
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      print('PUT Error $endpoint: $e');
      rethrow;
    }
  }

  // DELETE
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse(response);
    } catch (e) {
      print('DELETE Error $endpoint: $e');
      rethrow;
    }
  }
}
