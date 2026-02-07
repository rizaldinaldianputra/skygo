import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/order_request.dart';
import '../services/order_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart'; // Import if needed for auth check
import '../session/session_manager.dart';
import 'waiting_driver_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final OrderService _orderService = OrderService();
  final LocationService _locationService = LocationService();

  // Controllers for TextFields
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // State
  LatLng _currentCenter = const LatLng(-6.200000, 106.816666);
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];
  double _distanceKm = 0;
  double _price = 0;

  bool _isLoading = true;
  bool _isPickupFocused = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng pos = LatLng(position.latitude, position.longitude);
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    // Reverse geocode to get address
    // Ideally call location service to get address
    //For now just use generic text or empty, validation can happen on order

    try {
      // Simple reverse geocode mock or use existing search if supported
      // _locationService doesn't have reverse geocode public method in snippet
      // We will just set coordinates
    } catch (e) {}

    setState(() {
      _currentCenter = pos;
      _isLoading = false;
      // If user clicked the "My Location" icon in pickup field, set it
      if (_isPickupFocused) {
        _pickupLocation = pos;
        _pickupController.text =
            placemarks.first.street ?? ''; // Or fetch real address
      }
    });
    _mapController.move(_currentCenter, 15.0);
  }

  void _onLocationSelected(Map<String, dynamic> suggestion, bool isPickup) {
    LatLng point = LatLng(suggestion['lat'], suggestion['lon']);
    String address = suggestion['display_name'];

    setState(() {
      if (isPickup) {
        _pickupLocation = point;
        _pickupController.text = address;
      } else {
        _destinationLocation = point;
        _destinationController.text = address;
      }
      _mapController.move(point, 15.0);
    });

    if (_pickupLocation != null && _destinationLocation != null) {
      _calculateRoute();
    }
  }

  void _calculateRoute() async {
    setState(() => _isLoading = true);
    final routeData = await _locationService.getRoute(
      _pickupLocation!,
      _destinationLocation!,
    );

    if (routeData != null) {
      List<LatLng> points = _locationService.parseRouteCoordinates(routeData);
      double dist = (routeData['distance'] ?? 0) / 1000.0; // meters to km

      setState(() {
        _routePoints = points;
        _distanceKm = dist;
        // Default price if backend fails
        _price = dist * 3000;
        if (_price < 10000) _price = 10000;
        _isLoading = false;
      });

      // Fit bounds
      if (points.isNotEmpty) {
        LatLngBounds bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      }

      // Call Backend for Price Estimate
      final estimate = await _orderService.getFareEstimate(
        _pickupLocation!.latitude,
        _pickupLocation!.longitude,
        _destinationLocation!.latitude,
        _destinationLocation!.longitude,
      );

      if (estimate != null) {
        setState(() {
          _price = (estimate['estimatedPrice'] as num).toDouble();
          _distanceKm = (estimate['distanceKm'] as num).toDouble();
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Could not find route")));
      }
    }
  }

  void _showOrderConfirmation() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Konfirmasi Pesanan",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              // Addresses
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.my_location, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lokasi Jemput",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _pickupController.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tujuan",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _destinationController.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Jarak"),
                  Text(
                    "${_distanceKm.toStringAsFixed(1)} km",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Harga Estimasi"),
                  Text(
                    "Rp ${_price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Oke Lanjut",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createOrder() async {
    Navigator.pop(context); // Close sheet
    setState(() => _isLoading = true);

    // Get user ID from session
    final sessionManager = SessionManager(); // Or inject
    // Assuming SessionManager has getUserId method, or we get it from token/saved session
    // Let's add getUserId to SessionManager if missing, or use a heuristic.
    // For now, I will use a placeholder that tries to get it.
    // Actually, SessionManager.saveSession saves (token, userId, name).
    // I should add getUserId to SessionManager or read it.

    // Changing to read from SessionManager
    String? userIdStr = await sessionManager.getUserId();
    int userId = userIdStr != null ? int.parse(userIdStr) : 1;

    OrderRequest request = OrderRequest(
      userId: userId,
      pickupAddress: _pickupController.text,
      pickupLat: _pickupLocation!.latitude,
      pickupLng: _pickupLocation!.longitude,
      destinationAddress: _destinationController.text,
      destinationLat: _destinationLocation!.latitude,
      destinationLng: _destinationLocation!.longitude,
    );

    bool success = await _orderService.createOrder(request);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        // Navigate to Waiting Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingDriverPage(
              orderId: 0, // Placeholder
              pickup: _pickupLocation!,
              destination: _destinationLocation!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to create order. Please login."),
          ),
        );
      }
    }
  }

  Widget _buildTypeAhead(
    String hint,
    TextEditingController controller,
    bool isPickup,
  ) {
    return TypeAheadField<Map<String, dynamic>>(
      controller: controller,
      suggestionsCallback: (pattern) async {
        if (pattern.length < 3) return [];
        return await _locationService.searchAddress(pattern);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(
            Icons.location_on,
            color: isPickup ? Colors.green : Colors.red,
          ),
          title: Text(suggestion['display_name']),
          subtitle: Text(
            "${suggestion['type']} - ${suggestion['addresstype']}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      },
      onSelected: (suggestion) => _onLocationSelected(suggestion, isPickup),
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onTap: () {
            setState(() {
              _isPickupFocused = isPickup;
            });
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              Icons.search,
              color: isPickup ? Colors.green : Colors.red,
            ),
            suffixIcon: isPickup
                ? IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _isPickupFocused = true;
                      });
                      _getCurrentLocation();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 15,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent map resize on keyboard
      body: Stack(
        children: [
          // MAP LAYER
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.skygo.user',
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
                  if (_pickupLocation != null)
                    Marker(
                      point: _pickupLocation!,
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  if (_destinationLocation != null)
                    Marker(
                      point: _destinationLocation!,
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // TOP SEARCH BAR LAYER
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildTypeAhead("Pickup Location", _pickupController, true),
                const SizedBox(height: 10),
                _buildTypeAhead("Destination", _destinationController, false),
              ],
            ),
          ),

          // ORDER BUTTON (Visible only when route is calculated)
          if (_routePoints.isNotEmpty && !_isLoading)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showOrderConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Pesan Sekarang",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // LOADING
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // BACK BUTTON
          if (!_isLoading) // Hide when loading to prevent accidental clicks
            Positioned(
              top: 40,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
