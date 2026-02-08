import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../core/dio_client.dart';
import '../config/api_config.dart';
import '../session/session_manager.dart';
import '../core/toast_service.dart';

class TrackingService {
  final Dio _dio = DioClient().dio;
  final SessionManager _sessionManager = SessionManager();

  // Sends current location to backend
  Future<bool> updateLocation(double lat, double lng) async {
    try {
      final String? userIdStr = await _sessionManager.getUserId();
      if (userIdStr == null) return false;

      final int driverId = int.parse(userIdStr);

      final Map<String, dynamic> payload = {
        "driverId": driverId,
        "lat": lat,
        "lng": lng,
      };

      await _dio.post(ApiConfig.trackingUpdateEndpoint, data: payload);

      return true;
    } catch (e) {
      print("Tracking update error: $e");
      return false;
    }
  }

  // Toggle availability
  Future<bool> setAvailability(bool isOnline) async {
    try {
      final String? userIdStr = await _sessionManager.getUserId();
      if (userIdStr == null) return false;

      final String url = isOnline
          ? ApiConfig.driverOnlineEndpoint.replaceFirst("{id}", userIdStr)
          : ApiConfig.driverOfflineEndpoint.replaceFirst("{id}", userIdStr);

      final response = await _dio.post(url);

      if (response.statusCode == 200) {
        ToastService.showSuccess(
          isOnline ? "You are now ONLINE" : "You are now OFFLINE",
        );
        return true;
      }
      return false;
    } catch (e) {
      print("Availability error: $e");
      return false;
    }
  }

  // Helper to get current device position
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ToastService.showError("Location services are disabled.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ToastService.showError("Location permissions are denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ToastService.showError("Location permissions are permanently denied.");
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }
}
