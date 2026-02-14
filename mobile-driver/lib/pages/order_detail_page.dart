import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'chat_page.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService _orderService = OrderService();
  Order? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final data = await _orderService.getOrderDetails(widget.orderId);
    if (data != null) {
      setState(() {
        _order = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null)
      return const Scaffold(body: Center(child: Text('Order not found')));

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Earnings',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp ${_order!.estimatedPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Passenger Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(_order!.user?.name ?? 'User ID: ${_order!.userId}'),
                subtitle: _order!.user?.phone != null
                    ? Text(_order!.user!.phone!)
                    : null,
              ),
            ),
            // Chat button for active orders
            if (_order!.status == 'ACCEPTED' ||
                _order!.status == 'PICKUP' ||
                _order!.status == 'ONGOING')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            orderId: widget.orderId,
                            userName: _order!.user?.name ?? 'Penumpang',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text(
                      'Chat Penumpang',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            const Text(
              'Trip Route',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.my_location, 'Pickup', _order!.pickupAddress),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.location_on,
              'Destination',
              _order!.destinationAddress,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.map,
              'Distance',
              '${_order!.distanceKm.toStringAsFixed(2)} km',
            ),

            const SizedBox(height: 30),

            if (_order!.rating != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Feedback',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Rating: '),
                              Icon(Icons.star, color: Colors.amber),
                              Text('${_order!.rating} / 5'),
                            ],
                          ),
                          if (_order!.feedback != null &&
                              _order!.feedback!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '"${_order!.feedback}"',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
