import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DiscountSelector extends StatefulWidget {
  final String? selectedDiscountCode;
  final double orderAmount;
  final Function(String?, double) onDiscountSelected; // code, discountAmount

  const DiscountSelector({
    Key? key,
    this.selectedDiscountCode,
    required this.orderAmount,
    required this.onDiscountSelected,
  }) : super(key: key);

  @override
  _DiscountSelectorState createState() => _DiscountSelectorState();
}

class _DiscountSelectorState extends State<DiscountSelector> {
  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _discounts = [];
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDiscounts();
  }

  void _loadDiscounts() async {
    try {
      final discounts = await _dashboardService.getDiscounts();
      if (mounted) {
        setState(() {
          // Filter discounts applicable for the order amount
          _discounts = discounts.where((d) {
            final minOrder = (d['minOrderAmount'] as num?)?.toDouble() ?? 0;
            return minOrder <= widget.orderAmount;
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading discounts: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateDiscount(Map<String, dynamic> discount) {
    final type = discount['discountType'] as String? ?? 'FIXED';
    final value = (discount['discountValue'] as num?)?.toDouble() ?? 0;

    if (type == 'PERCENTAGE') {
      return widget.orderAmount * value / 100;
    } else {
      return value;
    }
  }

  String _formatDiscount(Map<String, dynamic> discount) {
    final type = discount['discountType'] as String? ?? 'FIXED';
    final value = (discount['discountValue'] as num?)?.toDouble() ?? 0;

    if (type == 'PERCENTAGE') {
      return '${value.toInt()}%';
    } else {
      return 'Rp ${value.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink(); // Don't show anything while loading
    }

    if (_discounts.isEmpty) {
      return const SizedBox.shrink(); // No discounts available
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Pakai Diskon",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.selectedDiscountCode != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      widget.selectedDiscountCode!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // "No Discount" option
                _buildDiscountOption(
                  null,
                  "Tanpa Diskon",
                  "",
                  null,
                  isSelected: widget.selectedDiscountCode == null,
                ),
                const Divider(height: 1),
                // Discount options
                ..._discounts.map((discount) {
                  final code = discount['code'] as String;
                  final description = discount['description'] as String? ?? '';
                  final discountAmount = _calculateDiscount(discount);
                  final discountLabel = _formatDiscount(discount);

                  return Column(
                    children: [
                      _buildDiscountOption(
                        code,
                        code,
                        '${description.isNotEmpty ? "$description — " : ""}Diskon $discountLabel',
                        discountAmount,
                        isSelected: widget.selectedDiscountCode == code,
                      ),
                      const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDiscountOption(
    String? code,
    String title,
    String subtitle,
    double? discountAmount, {
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: () {
        widget.onDiscountSelected(code, discountAmount ?? 0);
        setState(() => _isExpanded = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: isSelected ? Colors.green.shade50 : null,
        child: Row(
          children: [
            Icon(
              code == null ? Icons.close : Icons.local_offer,
              color: isSelected ? Colors.green : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected
                          ? Colors.green.shade800
                          : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            if (discountAmount != null && discountAmount > 0)
              Text(
                "-Rp ${discountAmount.toStringAsFixed(0)}",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.check_circle, color: Colors.green, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
