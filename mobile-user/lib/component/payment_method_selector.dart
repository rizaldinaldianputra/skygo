import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/dashboard_service.dart';

class PaymentMethodSelector extends StatefulWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;
  final Function(File?) onImageSelected;

  const PaymentMethodSelector({
    Key? key,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  _PaymentMethodSelectorState createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  final ImagePicker _picker = ImagePicker();
  final DashboardService _dashboardService = DashboardService();
  File? _imageFile;
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  void _loadPaymentMethods() async {
    try {
      final methods = await _dashboardService.getPaymentMethods();
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
          _isLoading = false;
        });
        // Auto-select first if current selection not in list
        if (methods.isNotEmpty) {
          final codes = methods.map((m) => m['code'] as String).toList();
          if (!codes.contains(widget.selectedMethod)) {
            widget.onMethodSelected(codes.first);
          }
        }
      }
    } catch (e) {
      print('Error loading payment methods: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      widget.onImageSelected(_imageFile);
    }
  }

  IconData _getIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'CASH':
        return Icons.money;
      case 'WALLET':
        return Icons.account_balance_wallet;
      case 'BANK':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Color _getColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'CASH':
        return Colors.green;
      case 'WALLET':
        return Colors.blue;
      case 'BANK':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // Fallback to hardcoded if no methods from API
    if (_paymentMethods.isEmpty) {
      return _buildFallbackSelector();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Metode Pembayaran",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  _paymentMethods.any((m) => m['code'] == widget.selectedMethod)
                  ? widget.selectedMethod
                  : _paymentMethods.first['code'] as String,
              isExpanded: true,
              items: _paymentMethods.map((method) {
                final code = method['code'] as String;
                final name = method['name'] as String? ?? code;
                final type = method['type'] as String?;
                return DropdownMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      Icon(_getIcon(type), color: _getColor(type)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(name)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onMethodSelected(value);
                  if (value == 'CASH') {
                    setState(() => _imageFile = null);
                    widget.onImageSelected(null);
                  }
                }
              },
            ),
          ),
        ),
        // Show instructions if available
        ..._buildInstructions(),
        // Show payment proof upload for non-CASH methods
        // if (widget.selectedMethod != 'CASH') ...[
        //   const SizedBox(height: 15),
        //   const Text(
        //     "Bukti Pembayaran",
        //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        //   ),
        //   const SizedBox(height: 8),
        //   GestureDetector(
        //     onTap: _pickImage,
        //     child: Container(
        //       height: 100,
        //       width: double.infinity,
        //       decoration: BoxDecoration(
        //         color: Colors.grey[100],
        //         borderRadius: BorderRadius.circular(10),
        //         border: Border.all(color: Colors.grey[300]!),
        //       ),
        //       child: _imageFile != null
        //           ? ClipRRect(
        //               borderRadius: BorderRadius.circular(10),
        //               child: Image.file(_imageFile!, fit: BoxFit.cover),
        //             )
        //           : const Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Icon(Icons.cloud_upload, color: Colors.blue, size: 30),
        //                 SizedBox(height: 5),
        //                 Text(
        //                   "Upload Bukti Transfer/E-Wallet",
        //                   style: TextStyle(color: Colors.grey),
        //                 ),
        //               ],
        //             ),
        //     ),
        //   ),
        // ],
      ],
    );
  }

  List<Widget> _buildInstructions() {
    final selected = _paymentMethods.firstWhere(
      (m) => m['code'] == widget.selectedMethod,
      orElse: () => {},
    );
    final instructions = selected['instructions'] as String?;
    if (instructions == null || instructions.isEmpty) return [];
    return [
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                instructions,
                style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildFallbackSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Metode Pembayaran",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.selectedMethod,
              isExpanded: true,
              items: [
                _buildDropdownItem("CASH", "Tunai", Icons.money, Colors.green),
                _buildDropdownItem(
                  "WALLET",
                  "SkyPay",
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
                _buildDropdownItem(
                  "TRANSFER",
                  "Transfer Bank",
                  Icons.account_balance,
                  Colors.orange,
                ),
              ],
              onChanged: (value) {
                if (value != null) widget.onMethodSelected(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
