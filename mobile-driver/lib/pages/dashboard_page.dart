import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  final SessionManager _sessionManager = SessionManager();
  bool _isOnline = false;
  Timer? _trackingTimer;
  LatLng _currentPosition = const LatLng(-6.2088, 106.8456); // Default Jakarta
  final MapController _mapController = MapController();

  String _driverName = "Driver";

  @override
  void initState() {
    super.initState();
    _loadDriverInfo();
    _getCurrentLocation();
  }

  void _loadDriverInfo() async {
    final name = await _sessionManager.getName();
    // In a real app, we might store more info in session or fetch profile
    // For now, using name from session.
    setState(() {
      _driverName = name ?? "Driver";
    });
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _toggleAvailability(bool value) async {
    bool success = await _trackingService.setAvailability(value);

    if (success) {
      setState(() {
        _isOnline = value;
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
    _sendLocationUpdate();
    _trackingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendLocationUpdate();
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
  }

  void _getCurrentLocation() async {
    final position = await _trackingService.getCurrentPosition();
    if (position != null) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition, 15);
    }
  }

  void _sendLocationUpdate() async {
    final position = await _trackingService.getCurrentPosition();
    if (position != null) {
      print("Updating location: ${position.latitude}, ${position.longitude}");
      await _trackingService.updateLocation(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_driverName, style: const TextStyle(fontSize: 16)),
            // We might need to fetch vehicle plate from profile API in future
            // const Text("B 1234 XYZ", style: TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: _isOnline ? Colors.green : const Color(0xFF00BFFF),
        actions: [
          Row(
            children: [
              Text(
                _isOnline ? "ONLINE" : "OFFLINE",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _isOnline,
                onChanged: _toggleAvailability,
                activeColor: Colors.white,
                activeTrackColor: Colors.lightGreenAccent,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _stopTracking();
              await _trackingService.setAvailability(false);
              await _sessionManager.clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _currentPosition, initialZoom: 15.0),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.local_taxi,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
