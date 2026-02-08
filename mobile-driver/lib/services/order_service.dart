import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../config/api_config.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio = DioClient().dio;

  // Headers are now handled by AuthInterceptor

  Future<List<Order>> getHistory(int driverId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/orders/history',
        queryParameters: {'userId': driverId.toString(), 'role': 'DRIVER'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Changed to 'success' based on old code, but usually it's 'status' in ApiResponse. Maintaining 'success' for now if that's what was there, but typically consistent. The old code had success.
          final List list = data['data'];
          return list.map((json) => Order.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      // Error handled by Interceptor
      return [];
    }
  }

  Future<Order?> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Order.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      // Error handled by Interceptor
      return null;
    }
  }
}
