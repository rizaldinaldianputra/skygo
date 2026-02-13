import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrderAcceptanceDialog extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final OrderService _orderService = OrderService();

  OrderAcceptanceDialog({Key? key, required this.orderData}) : super(key: key);

  Future<void> _acceptOrder(BuildContext context) async {
    try {
      String orderIdStr = orderData['orderId'].toString();
      int orderId = int.parse(orderIdStr);

      bool success = await _orderService.acceptOrder(orderId);

      if (success) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order Accepted! Heading to pickup.")),
        );
        // The dashboard listener will refresh or we can add a callback
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to accept order.")),
        );
      }
    } catch (e) {
      print("Error accepting order: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse price to double for proper formatting if possible, else just show
    String price = orderData['price'] ?? '0';
    String distance = orderData['distance'] ?? '0';

    return AlertDialog(
      title: const Text("New Order Available!"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.my_location,
              "Pickup",
              orderData['pickupAddress'],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.location_on,
              "Destination",
              orderData['destinationAddress'],
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Reject", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () => _acceptOrder(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Accept"),
        ),
      ],
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
}
