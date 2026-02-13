import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _imageFile;

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

  @override
  Widget build(BuildContext context) {
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
                  Icons.food_bank,
                  Colors.orange,
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  widget.onMethodSelected(value);
                  // Reset image if not needed, or keep it.
                  if (value == 'CASH') {
                    setState(() {
                      _imageFile = null;
                    });
                    widget.onImageSelected(null);
                  }
                }
              },
            ),
          ),
        ),
        if (widget.selectedMethod != 'CASH') ...[
          const SizedBox(height: 15),
          const Text(
            "Bukti Pembayaran",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cloud_upload, color: Colors.blue, size: 30),
                        SizedBox(height: 5),
                        Text(
                          "Upload Bukti Transfer/E-Wallet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
        ],
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
