import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../config/api_config.dart';
import '../session/session_manager.dart';

class TrackingService {
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

      final response = await http.post(
        Uri.parse(ApiConfig.trackingUpdateEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
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

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
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
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }
}
