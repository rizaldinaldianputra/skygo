class OrderRequest {
  final int userId;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;
  final String vehicleType;
  final String paymentMethod;
  final String? paymentProofUrl;

  OrderRequest({
    required this.userId,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.vehicleType,
    this.paymentMethod = 'CASH', // Default
    this.paymentProofUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationAddress': destinationAddress,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'vehicleType': vehicleType,
      'paymentMethod': paymentMethod,
      'paymentProofUrl': paymentProofUrl,
    };
  }
}
