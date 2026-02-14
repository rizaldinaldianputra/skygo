import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/order_service.dart';
import '../services/location_service.dart';
import '../models/order_model.dart';
import 'chat_page.dart';

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
  final OrderService _orderService = OrderService();
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  String _status = "REQUESTED";
  LatLng? _driverLocation;
  Order? _currentOrder;
  Timer? _pollTimer;
  List<LatLng> _routePoints = [];
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _fetchRoutePickupToDestination();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Fetch route from pickup to destination (shown while waiting)
  void _fetchRoutePickupToDestination() async {
    final routeData = await _locationService.getRoute(
      widget.pickup,
      widget.destination,
    );
    if (routeData != null && mounted) {
      List<LatLng> points = _locationService.parseRouteCoordinates(routeData);
      setState(() {
        _routePoints = points;
      });
      _fitBounds(points);
    }
  }

  /// Fetch route from driver to pickup (shown when driver is assigned)
  void _fetchRouteDriverToPickup(LatLng driverPos) async {
    final routeData = await _locationService.getRoute(driverPos, widget.pickup);
    if (routeData != null && mounted) {
      List<LatLng> points = _locationService.parseRouteCoordinates(routeData);
      setState(() {
        _routePoints = points;
      });
      _fitBounds(points);
    }
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    try {
      LatLngBounds bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
    } catch (e) {
      debugPrint("Error fitting bounds: $e");
    }
  }

  void _startPolling() {
    // Poll every 3 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // 1. Fetch order details to check status
      final orderData = await _orderService.getOrderDetails(widget.orderId);
      if (orderData != null && mounted) {
        final order = Order.fromJson(orderData);
        final previousStatus = _status;

        setState(() {
          _currentOrder = order;
          _status = order.status;
        });

        // 2. If driver assigned, fetch real driver location
        if (order.driverId != null &&
            (_status == "ACCEPTED" ||
                _status == "PICKUP" ||
                _status == "ONGOING")) {
          final locationData = await _orderService.getDriverLocation(
            order.driverId!,
          );
          if (locationData != null && mounted) {
            final lat = (locationData['lat'] as num).toDouble();
            final lng = (locationData['lng'] as num).toDouble();
            final newDriverPos = LatLng(lat, lng);

            setState(() {
              _driverLocation = newDriverPos;
            });

            // When status just changed to ACCEPTED, fetch route from driver to pickup
            if (previousStatus == "REQUESTED" && _status == "ACCEPTED") {
              _fetchRouteDriverToPickup(newDriverPos);
            }
          }
        }

        // 3. Handle terminal states
        if (_status == "COMPLETED" || _status == "CANCELLED") {
          timer.cancel();
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: Text(
                  _status == "COMPLETED"
                      ? "Perjalanan Selesai!"
                      : "Pesanan Dibatalkan",
                ),
                content: Text(
                  _status == "COMPLETED"
                      ? "Terima kasih telah menggunakan SkyGo!"
                      : "Pesanan Anda telah dibatalkan.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(); // Back to map/home
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        }
      }
    });
  }

  void _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isCancelling = true);
      final success = await _orderService.cancelOrder(widget.orderId);
      if (mounted) {
        setState(() => _isCancelling = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pesanan berhasil dibatalkan")),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal membatalkan pesanan")),
          );
        }
      }
    }
  }

  String _getStatusText() {
    switch (_status) {
      case "REQUESTED":
        return "Sedang Mencari Driver...";
      case "ACCEPTED":
        return "Driver Menuju Lokasi Anda";
      case "PICKUP":
        return "Driver Sudah di Lokasi Jemput";
      case "ONGOING":
        return "Perjalanan Sedang Berlangsung";
      case "COMPLETED":
        return "Perjalanan Selesai";
      case "CANCELLED":
        return "Pesanan Dibatalkan";
      default:
        return "Status: $_status";
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case "REQUESTED":
        return Icons.search;
      case "ACCEPTED":
        return Icons.directions_car;
      case "PICKUP":
        return Icons.location_on;
      case "ONGOING":
        return Icons.navigation;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWaiting = _status == "REQUESTED";

    return Scaffold(
      body: Stack(
        children: [
          // MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.pickup,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skygo.user',
              ),
              // Route polyline
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: isWaiting ? Colors.blue : Colors.green,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Pickup marker
                  Marker(
                    point: widget.pickup,
                    width: 60,
                    height: 60,
                    child: const Column(
                      children: [
                        Icon(Icons.location_on, color: Colors.green, size: 36),
                        Text(
                          "Jemput",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Destination marker
                  Marker(
                    point: widget.destination,
                    width: 60,
                    height: 60,
                    child: const Column(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 36),
                        Text(
                          "Tujuan",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Driver marker (real-time)
                  if (_driverLocation != null)
                    Marker(
                      point: _driverLocation!,
                      width: 60,
                      height: 60,
                      child: const Column(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Colors.blue,
                            size: 36,
                          ),
                          Text(
                            "Driver",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // STATUS BAR at top
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (isWaiting)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  else
                    Icon(_getStatusIcon(), color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM SHEET - Driver Info or Cancel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // If waiting
                  if (isWaiting) ...[
                    const Icon(Icons.search, size: 48, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      "Mencari driver terdekat...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Mohon tunggu, kami sedang mencarikan driver untuk Anda",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCancelling ? null : _cancelOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isCancelling
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Batalkan Pesanan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],

                  // If driver found
                  if (!isWaiting &&
                      _currentOrder != null &&
                      _currentOrder!.driverId != null) ...[
                    const Text(
                      "Driver Ditemukan!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      title: Text(
                        _currentOrder!.driverName ?? "Driver",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_currentOrder!.driverVehicle ?? ''} - ${_currentOrder!.driverPlate ?? ''}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(
                                " ${_currentOrder!.driverRating?.toStringAsFixed(1) ?? '5.0'}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Status"),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Chat button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                orderId: widget.orderId,
                                driverName:
                                    _currentOrder!.driverName ?? 'Driver',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text(
                          'Chat Driver',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00880A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // LOADING overlay for cancelling
          if (_isCancelling)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
