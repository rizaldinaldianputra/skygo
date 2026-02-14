import '../services/api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final response = await _apiService.get('/public/banners');
      if (response != null && response['status'] == true) {
        final List list = response['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching banners: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPromos() async {
    try {
      final response = await _apiService.get('/public/promos');
      if (response != null && response['status'] == true) {
        final List list = response['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching promos: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getNews() async {
    try {
      final response = await _apiService.get('/public/news');
      if (response != null && response['status'] == true) {
        final List list = response['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }
}
