import 'dart:async';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ojekdriver/session/session_manager.dart';

class LocationService {
  Timer? _timer;
  final Dio _dio = Dio();
  final SessionManager _sessionManager = SessionManager();
  bool _isSending = false;

  // Singleton pattern
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  void startSendingLocation() {
    if (_timer != null && _timer!.isActive) return;

    print("LocationService: Starting location updates...");
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await _sendLocation();
    });
  }

  void stopSendingLocation() {
    print("LocationService: Stopping location updates...");
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendLocation() async {
    if (_isSending) return;
    _isSending = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("LocationService: Location services are disabled.");
        _isSending = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("LocationService: Location permissions are denied");
          _isSending = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
          "LocationService: Location permissions are permanently denied, we cannot request permissions.",
        );
        _isSending = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userIdStr = await _sessionManager.getUserId();
      if (userIdStr == null) {
        print("LocationService: No active session/driverId found.");
        _isSending = false;
        return;
      }

      String? token = await _sessionManager.getToken();
      int driverId = int.parse(userIdStr);

      // Assuming Backend URL is reachable. Replace with your actual backend URL.
      // Use 10.0.2.2 for Android Emulator to access localhost
      const String backendUrl = 'http://10.0.2.2:8080/api/tracking/update';

      print(
        "LocationService: Sending location for driver $driverId: ${position.latitude}, ${position.longitude}",
      );

      await _dio.post(
        backendUrl,
        data: {
          "driverId": driverId,
          "lat": position.latitude,
          "lng": position.longitude,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
    } catch (e) {
      print("LocationService: Error sending location: $e");
    } finally {
      _isSending = false;
    }
  }
}
