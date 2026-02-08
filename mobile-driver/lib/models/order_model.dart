class Order {
  final int id;
  final int userId;
  final int? driverId;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;
  final double distanceKm;
  final double estimatedPrice;
  final String status;
  final int? rating;
  final String? feedback;
  final String createdAt;

  Order({
    required this.id,
    required this.userId,
    this.driverId,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.distanceKm,
    required this.estimatedPrice,
    required this.status,
    this.rating,
    this.feedback,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user']['id'],
      driverId: json['driver'] != null ? json['driver']['id'] : null,
      pickupAddress: json['pickupAddress'],
      pickupLat: json['pickupLat'],
      pickupLng: json['pickupLng'],
      destinationAddress: json['destinationAddress'],
      destinationLat: json['destinationLat'],
      destinationLng: json['destinationLng'],
      distanceKm: json['distanceKm'],
      estimatedPrice: json['estimatedPrice'],
      status: json['status'],
      rating: json['rating'],
      feedback: json['feedback'],
      createdAt: json['createdAt'],
    );
  }
}
