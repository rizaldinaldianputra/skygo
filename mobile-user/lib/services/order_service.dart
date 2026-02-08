import '../models/order_request.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

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
        if (response['success'] == true && response['data'] != null) {
          return response['data'];
        }
      }
      return null;
    } catch (e) {
      print("Error getting estimate: $e");
      return null;
    }
  }

  Future<bool> createOrder(OrderRequest request) async {
    try {
      final response = await _apiService.post(
        '/orders/create',
        body: request.toJson(),
      );

      if (response != null && response is Map) {
        // Check success flag or similar if your API returns it
        // Assuming standard ApiResponse with 'success': true
        if (response['success'] == true) return true;
        // If response is just the order object, it's also true
        return true;
      }
      return false;
    } catch (e) {
      print("Error creating order: $e");
      rethrow; // Rethrow to let UI handle it
    }
  }

  Future<List<dynamic>> getHistory(int userId) async {
    try {
      final response = await _apiService.get(
        '/orders/history',
        queryParameters: {'userId': userId, 'role': 'USER'},
      );
      if (response != null && response is Map && response['success'] == true) {
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
      if (response != null && response is Map && response['success'] == true) {
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
      if (response != null && response is Map && response['success'] == true) {
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
      if (response != null && response is Map && response['success'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print("Error getting invoice: $e");
      return null;
    }
  }
}
