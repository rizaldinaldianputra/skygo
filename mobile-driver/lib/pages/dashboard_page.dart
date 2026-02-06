import 'package:flutter/material.dart';
import 'dart:async';
import '../services/tracking_service.dart';
import '../session/session_manager.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TrackingService _trackingService = TrackingService();
  bool _isOnline = false;
  Timer? _trackingTimer;
  String _statusMessage = "You are OFFLINE";

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _toggleAvailability() async {
    bool newState = !_isOnline;
    bool success = await _trackingService.setAvailability(newState);

    if (success) {
      setState(() {
        _isOnline = newState;
        _statusMessage = _isOnline ? "You are ONLINE" : "You are OFFLINE";
      });

      if (_isOnline) {
        _startTracking();
      } else {
        _stopTracking();
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update status")));
    }
  }

  void _startTracking() {
    // Immediate update
    _sendLocationUpdate();
    // Periodic update every 10 seconds
    _trackingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendLocationUpdate();
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
  }

  void _sendLocationUpdate() async {
    final position = await _trackingService.getCurrentPosition();
    if (position != null) {
      print("Updating location: ${position.latitude}, ${position.longitude}");
      await _trackingService.updateLocation(
        position.latitude,
        position.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SkyGo Driver"),
        backgroundColor: _isOnline ? Colors.green : const Color(0xFF00BFFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _stopTracking();
              await _trackingService.setAvailability(false); // Ensure offline
              await SessionManager().clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOnline ? Icons.local_taxi : Icons.car_rental,
              size: 100,
              color: _isOnline ? Colors.green : const Color(0xFF87CEEB),
            ),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isOnline ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _toggleAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOnline ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _isOnline ? "GO OFFLINE" : "GO ONLINE",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
