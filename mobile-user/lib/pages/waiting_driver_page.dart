import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import '../services/order_service.dart'; // Uncomment when needed
// import '../models/order_model.dart'; // Uncomment when needed

class WaitingDriverPage extends StatefulWidget {
  final int orderId;
  final LatLng pickup;
  final LatLng destination;

  const WaitingDriverPage({
    Key? key,
    required this.orderId,
    required this.pickup,
    required this.destination,
  }) : super(key: key);

  @override
  State<WaitingDriverPage> createState() => _WaitingDriverPageState();
}

class _WaitingDriverPageState extends State<WaitingDriverPage> {
  // OrderService _orderService = OrderService();
  String _status =
      "WAITING"; // WAITING, ACCEPTED, ON_THE_WAY, ARRIVED, STARTED, COMPLETED
  LatLng? _driverLocation;

  // Mock driver movement
  // In real app, listen to WebSocket or poll API

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() async {
    // Simulate finding a driver after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _status = "ACCEPTED";
        // Mock driver location near pickup
        _driverLocation = LatLng(
          widget.pickup.latitude - 0.005,
          widget.pickup.longitude - 0.005,
        );
      });

      // Simulate driver moving
      _simulateDriverMovement();
    }
  }

  void _simulateDriverMovement() async {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _driverLocation = LatLng(
          _driverLocation!.latitude + 0.0005,
          _driverLocation!.longitude + 0.0005,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWaiting = _status == "WAITING";

    return Scaffold(
      appBar: AppBar(
        title: Text(isWaiting ? "Mencari Driver..." : "Driver Menuju Lokasi"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Map Background (Always visible, but focused on driver when found)
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.pickup,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skygo.user',
              ),
              MarkerLayer(
                markers: [
                  // Pickup
                  Marker(
                    point: widget.pickup,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  // Destination
                  Marker(
                    point: widget.destination,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  // Driver
                  if (_driverLocation != null)
                    Marker(
                      point: _driverLocation!,
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Waiting Overlay
          if (isWaiting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "Sedang Mencari Driver...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

          // Driver Info Sheet
          if (!isWaiting)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Driver Ditemukan!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Status: $_status"),
                    const SizedBox(height: 10),
                    // In real app, show driver name, plate, etc.
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
