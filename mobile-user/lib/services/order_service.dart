import '../models/order_request.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  /// Helper to check if response indicates success
  bool _isSuccess(Map response) {
    return response['status'] == true || response['success'] == true;
  }

  Future<Map<String, dynamic>?> getFareEstimate(
    double pickupLat,
    double pickupLng,
    double destinationLat,
    double destinationLng,
  ) async {
    try {
      final response = await _apiService.post(
        '/orders/estimate-fare',
        body: {
          'pickupLat': pickupLat,
          'pickupLng': pickupLng,
          'destinationLat': destinationLat,
          'destinationLng': destinationLng,
        },
      );

      if (response != null && response is Map) {
        if (_isSuccess(response) && response['data'] != null) {
          return response['data'];
        }
      }
      return null;
    } catch (e) {
      print("Error getting estimate: $e");
      return null;
    }
  }

  Future<Order?> createOrder(OrderRequest request) async {
    try {
      final response = await _apiService.post(
        '/orders/create',
        body: request.toJson(),
      );

      if (response != null && response is Map) {
        if (_isSuccess(response) && response['data'] != null) {
          return Order.fromJson(response['data']);
        }
      }
      return null;
    } catch (e) {
      print("Error creating order: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getHistory(int userId) async {
    try {
      final response = await _apiService.get(
        '/orders/history',
        queryParameters: {'userId': userId, 'role': 'USER'},
      );
      if (response != null && response is Map && _isSuccess(response)) {
        return response['data'];
      }
      return [];
    } catch (e) {
      print("Error getting history: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getOrderDetails(int orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');
      if (response != null && response is Map && _isSuccess(response)) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print("Error getting details: $e");
      return null;
    }
  }

  Future<bool> rateOrder(int orderId, int rating, String feedback) async {
    try {
      final response = await _apiService.post(
        '/orders/$orderId/rate',
        body: {'rating': rating, 'feedback': feedback},
      );
      if (response != null && response is Map && _isSuccess(response)) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error rating order: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getInvoice(int orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/invoice');
      if (response != null && response is Map && _isSuccess(response)) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print("Error getting invoice: $e");
      return null;
    }
  }

  /// Get driver location for a specific order's assigned driver
  Future<Map<String, dynamic>?> getDriverLocation(int driverId) async {
    try {
      final response = await _apiService.get(
        '/tracking/driver/$driverId/location',
      );
      if (response != null && response is Map && _isSuccess(response)) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print("Error getting driver location: $e");
      return null;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await _apiService.post('/orders/$orderId/cancel');
      if (response != null && response is Map && _isSuccess(response)) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error cancelling order: $e");
      return false;
    }
  }
}
