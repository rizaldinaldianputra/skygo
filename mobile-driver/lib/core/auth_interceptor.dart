import 'package:dio/dio.dart';
import '../session/session_manager.dart';

class AuthInterceptor extends Interceptor {
  final SessionManager _sessionManager = SessionManager();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _sessionManager.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
