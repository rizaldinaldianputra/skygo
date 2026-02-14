import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import '../config/api_config.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio = DioClient().dio;

  /// Helper to check if response indicates success (backend uses 'status')
  bool _isSuccess(Map<String, dynamic> data) {
    return data['status'] == true || data['success'] == true;
  }

  Future<List<Order>> getHistory(int driverId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/orders/history',
        queryParameters: {'userId': driverId.toString(), 'role': 'DRIVER'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (_isSuccess(data)) {
          final List list = data['data'];
          return list.map((json) => Order.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Order?> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (_isSuccess(data)) {
          return Order.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Order>> getAvailableOrders() async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/orders/available');

      if (response.statusCode == 200) {
        final data = response.data;
        if (_isSuccess(data)) {
          // Backend returns paginated Page<Order> with {content: [...], totalElements, ...}
          // Handle both paginated and flat list responses
          final dynamic responseData = data['data'];
          final List list;
          if (responseData is List) {
            list = responseData;
          } else if (responseData is Map &&
              responseData.containsKey('content')) {
            list = responseData['content'] ?? [];
          } else {
            list = [];
          }
          return list.map((json) => Order.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching available orders: $e");
      return [];
    }
  }

  Future<bool> acceptOrder(int orderId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/orders/$orderId/accept',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return _isSuccess(data);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startTrip(int orderId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/orders/$orderId/start',
      );
      if (response.statusCode == 200) {
        return _isSuccess(response.data);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> finishTrip(int orderId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/orders/$orderId/finish',
      );
      if (response.statusCode == 200) {
        return _isSuccess(response.data);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
