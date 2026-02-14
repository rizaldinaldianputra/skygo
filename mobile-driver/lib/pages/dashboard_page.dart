import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/tracking_service.dart';
import '../services/order_service.dart';
import '../services/websocket_service.dart';
import '../session/session_manager.dart';
import '../models/order_model.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TrackingService _trackingService = TrackingService();
  final OrderService _orderService = OrderService();
  final SessionManager _sessionManager = SessionManager();
  final WebSocketService _webSocketService = WebSocketService();

  bool _isOnline = false;
  Timer? _trackingTimer;

  LatLng _currentPosition = const LatLng(-6.2088, 106.8456);
  final MapController _mapController = MapController();

  List<LatLng> _routePoints = [];

  String _driverName = "Driver";

  // Active order tracking
  Order? _activeOrder;
  LatLng? _activeOrderPickup;
  LatLng? _activeOrderDestination;

  @override
  void initState() {
    super.initState();
    _loadDriverInfo();
    _getCurrentLocation();
    _setupWebSocket();
  }

  /// Setup WebSocket callback for incoming orders
  void _setupWebSocket() {
    _webSocketService.onOrderReceived = (Map<String, dynamic> data) {
      if (_isOnline && _activeOrder == null) {
        _handleNewOrderNotification(data);
      }
    };
  }

  /// Handle incoming WebSocket order message
  void _handleNewOrderNotification(Map<String, dynamic> data) async {
    try {
      // WebSocket sends full order object from backend
      // Try parsing it directly as Order first
      final order = Order.fromJson(data);
      if (!mounted) return;
      _showNewOrderDialog(order);
    } catch (e) {
      print("Error parsing WebSocket order: $e");
      // Fallback: try fetching by orderId
      try {
        final orderId = data['id'] ?? data['orderId'];
        if (orderId != null) {
          final order = await _orderService.getOrderDetails(
            int.parse(orderId.toString()),
          );
          if (order != null && mounted) {
            _showNewOrderDialog(order);
            return;
          }
        }
      } catch (_) {}
      // Last fallback: simple dialog with raw data
      _showSimpleOrderDialog(data);
    }
  }

  void _showSimpleOrderDialog(Map<String, dynamic> data) {
    if (!mounted) return;

    String price = data['price']?.toString() ?? '0';
    String distance = data['distance']?.toString() ?? '0';
    String orderId = data['orderId']?.toString() ?? '0';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.notifications_active, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text("Pesanan Baru!")),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.my_location,
              "Jemput",
              data['pickupAddress']?.toString(),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.location_on,
              "Tujuan",
              data['destinationAddress']?.toString(),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTag(Icons.attach_money, "Rp $price", Colors.green),
                _buildTag(Icons.directions_car, "$distance km", Colors.blue),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tolak", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool success = await _orderService.acceptOrder(
                int.parse(orderId),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pesanan diterima!"),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh to get the accepted order
                final order = await _orderService.getOrderDetails(
                  int.parse(orderId),
                );
                if (order != null && mounted) {
                  _setActiveOrder(order);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Terima Pesanan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showNewOrderDialog(Order order) async {
    // Calculate route from driver → pickup
    List<LatLng> dialogRoutePoints = [];
    final pickup = LatLng(order.pickupLat, order.pickupLng);

    try {
      final route = await _trackingService.getRoute(_currentPosition, pickup);
      if (route != null) {
        dialogRoutePoints = _trackingService.parseRouteCoordinates(route);
      }
    } catch (e) {
      print("Error getting route for dialog: $e");
    }

    if (!mounted) return;

    final dialogMapController = MapController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.notifications_active, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(child: Text("Pesanan Baru!")),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: Column(
              children: [
                // User & price info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.user?.name ?? "Penumpang",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${order.distanceKm.toStringAsFixed(1)} km",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Rp ${order.estimatedPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Route map
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: dialogMapController,
                      options: MapOptions(
                        initialCenter: _currentPosition,
                        initialZoom: 13.0,
                        onMapReady: () {
                          if (dialogRoutePoints.isNotEmpty) {
                            try {
                              dialogMapController.fitCamera(
                                CameraFit.bounds(
                                  bounds: LatLngBounds.fromPoints(
                                    dialogRoutePoints,
                                  ),
                                  padding: const EdgeInsets.all(30),
                                ),
                              );
                            } catch (e) {
                              debugPrint("Error fitting dialog bounds: $e");
                            }
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.skycosmic.driver',
                        ),
                        if (dialogRoutePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: dialogRoutePoints,
                                strokeWidth: 4.0,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                            Marker(
                              point: pickup,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Addresses
                Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.pickupAddress,
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.destinationAddress,
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tolak", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _acceptOrder(order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Terima Pesanan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _acceptOrder(Order order) async {
    bool success = await _orderService.acceptOrder(order.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pesanan diterima! Menuju lokasi jemput..."),
          backgroundColor: Colors.green,
        ),
      );
      _setActiveOrder(order);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal menerima pesanan. Pesanan mungkin sudah dibatalkan.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setActiveOrder(Order order) {
    final pickup = LatLng(order.pickupLat, order.pickupLng);
    final destination = LatLng(order.destinationLat, order.destinationLng);

    setState(() {
      _activeOrder = order;
      _activeOrderPickup = pickup;
      _activeOrderDestination = destination;
    });

    // Draw route from current position to pickup
    _fetchRouteForMainMap(_currentPosition, pickup);
  }

  void _fetchRouteForMainMap(LatLng from, LatLng to) async {
    final route = await _trackingService.getRoute(from, to);
    if (route != null && mounted) {
      final points = _trackingService.parseRouteCoordinates(route);
      if (points.isNotEmpty) {
        setState(() {
          _routePoints = points;
        });
        try {
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(points),
              padding: const EdgeInsets.all(50),
            ),
          );
        } catch (e) {
          debugPrint("Error fitting bounds: $e");
        }
      }
    }
  }

  void _startTrip() async {
    if (_activeOrder == null) return;
    final success = await _orderService.startTrip(_activeOrder!.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perjalanan dimulai!"),
          backgroundColor: Colors.blue,
        ),
      );
      if (_activeOrderPickup != null && _activeOrderDestination != null) {
        _fetchRouteForMainMap(_activeOrderPickup!, _activeOrderDestination!);
      }
    }
  }

  void _finishTrip() async {
    if (_activeOrder == null) return;
    final success = await _orderService.finishTrip(_activeOrder!.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perjalanan selesai!"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _activeOrder = null;
        _activeOrderPickup = null;
        _activeOrderDestination = null;
        _routePoints = [];
      });
    }
  }

  void _loadDriverInfo() async {
    final name = await _sessionManager.getName();
    if (mounted) {
      setState(() {
        _driverName = name ?? "Driver";
      });
    }
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

  void _toggleAvailability(bool value) async {
    bool success = await _trackingService.setAvailability(value);
    if (success && mounted) {
      setState(() {
        _isOnline = value;
      });
      if (_isOnline) {
        _startTracking();
        _webSocketService.connect(); // Connect WebSocket when going online
      } else {
        _stopTracking();
        _webSocketService
            .disconnect(); // Disconnect WebSocket when going offline
        setState(() {
          _routePoints = [];
          _activeOrder = null;
          _activeOrderPickup = null;
          _activeOrderDestination = null;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal update status")));
      }
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

  bool _isMapReady = false;

  void _getCurrentLocation() async {
    final position = await _trackingService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      if (_isMapReady) {
        _mapController.move(_currentPosition, 15);
      }
    }
  }

  void _sendLocationUpdate() async {
    final position = await _trackingService.getCurrentPosition();
    if (position != null && mounted) {
      await _trackingService.updateLocation(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isOnline ? "Online ($_driverName)" : "Offline"),
        backgroundColor: _isOnline ? Colors.green : Colors.grey,
        actions: [
          Switch(
            value: _isOnline,
            onChanged: _toggleAvailability,
            activeColor: Colors.white,
            activeTrackColor: Colors.lightGreenAccent,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _stopTracking();
              await _trackingService.setAvailability(false);
              await _sessionManager.clearSession();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // FULL-SCREEN MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15.0,
              onMapReady: () {
                _isMapReady = true;
                if (_currentPosition.latitude != -6.2088) {
                  _mapController.move(_currentPosition, 15);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skycosmic.driver',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Driver position
                  Marker(
                    point: _currentPosition,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.blue,
                      size: 36,
                    ),
                  ),
                  // Pickup marker
                  if (_activeOrderPickup != null)
                    Marker(
                      point: _activeOrderPickup!,
                      width: 60,
                      height: 60,
                      child: const Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 36,
                          ),
                          Text(
                            "Jemput",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Destination marker
                  if (_activeOrderDestination != null)
                    Marker(
                      point: _activeOrderDestination!,
                      width: 60,
                      height: 60,
                      child: const Column(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 36),
                          Text(
                            "Tujuan",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Status indicator when online but no active order
          if (_isOnline && _activeOrder == null)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.wifi, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Menunggu pesanan masuk...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Offline indicator
          if (!_isOnline)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.wifi_off, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Anda sedang offline. Aktifkan untuk menerima pesanan.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Active order actions overlay
          if (_activeOrder != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _activeOrder!.user?.name ?? "Penumpang",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          "Rp ${_activeOrder!.estimatedPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.my_location,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _activeOrder!.pickupAddress,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _activeOrder!.destinationAddress,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _startTrip,
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Mulai Jemput",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _finishTrip,
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Selesai",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
