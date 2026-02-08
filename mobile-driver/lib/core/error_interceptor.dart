import 'package:dio/dio.dart';
import 'toast_service.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = "Something went wrong";

    if (err.response != null) {
      try {
        final data = err.response!.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else if (data is String) {
          message = data;
        }
      } catch (e) {
        // failed to parse
      }
    } else {
      if (err.type == DioExceptionType.connectionTimeout) {
        message = "Connection timeout";
      } else if (err.type == DioExceptionType.receiveTimeout) {
        message = "Receive timeout";
      } else if (err.type == DioExceptionType.connectionError) {
        message = "No internet connection";
      }
    }

    ToastService.showError(message);
    super.onError(err, handler);
  }
}
