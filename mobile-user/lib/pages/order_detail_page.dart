import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

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
        _order = Order.fromJson(data);
        _isLoading = false;
      });
    }
  }

  void _showRatingDialog() {
    int rating = 5;
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rate Driver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: rating,
                items: List.generate(5, (index) => index + 1)
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e, child: Text('$e Stars')),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) rating = value;
                },
              ),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(labelText: 'Feedback'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _orderService.rateOrder(
                  widget.orderId,
                  rating,
                  feedbackController.text,
                );
                Navigator.pop(context);
                _fetchDetails(); // Refresh
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showInvoice() async {
    final invoiceData = await _orderService.getInvoice(widget.orderId);
    if (invoiceData != null) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'INVOICE',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
                Text('Order ID: ${invoiceData['id']}'),
                Text('Date: ${invoiceData['createdAt']}'),
                const SizedBox(height: 10),
                Text('Pickup: ${invoiceData['pickupAddress']}'),
                Text('Destination: ${invoiceData['destinationAddress']}'),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp ${invoiceData['estimatedPrice']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Simulate download
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invoice downloaded to device'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download PDF'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null)
      return const Scaffold(body: Center(child: Text('Order not found')));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      'Status: ${_order!.status}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Driver Info
            if (_order!.driverId != null) ...[
              const Text(
                'Driver Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Driver ID: ${_order!.driverId}'),
                  // In real app, we would resolve name or nested object
                  subtitle: const Text('Vehicle: Unknown'),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Trip Details
            const Text(
              'Trip Details',
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
              Icons.directions_car,
              'Distance',
              '${_order!.distanceKm.toStringAsFixed(2)} km',
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.attach_money,
              'Price',
              'Rp ${_order!.estimatedPrice.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 30),

            // Actions
            if (_order!.status == 'COMPLETED' && _order!.rating == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showRatingDialog,
                  icon: const Icon(Icons.star),
                  label: const Text('Rate Driver'),
                ),
              ),

            if (_order!.rating != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text("You rated this trip: ${_order!.rating} stars"),
                      if (_order!.feedback != null)
                        Text("Feedback: ${_order!.feedback}"),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showInvoice,
                icon: const Icon(Icons.receipt),
                label: const Text('View Invoice'),
              ),
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
              Text(
                value,
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
