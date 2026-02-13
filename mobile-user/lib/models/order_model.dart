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

  // Driver Details
  final String? driverName;
  final String? driverVehicle;
  final String? driverPlate;
  final double? driverRating;

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
    this.driverName,
    this.driverVehicle,
    this.driverPlate,
    this.driverRating,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user'] is Map ? json['user']['id'] : (json['userId'] ?? 0),
      driverId: json['driver'] != null && json['driver'] is Map
          ? json['driver']['id']
          : null,
      driverName: json['driver'] != null && json['driver'] is Map
          ? json['driver']['name']
          : null,
      driverVehicle: json['driver'] != null && json['driver'] is Map
          ? json['driver']['vehicleType']
          : null,
      driverPlate: json['driver'] != null && json['driver'] is Map
          ? json['driver']['vehiclePlate']
          : null,
      driverRating: json['driver'] != null && json['driver'] is Map
          ? _toDouble(json['driver']['rating'])
          : null,
      pickupAddress: json['pickupAddress'] ?? '',
      pickupLat: _toDouble(json['pickupLat']),
      pickupLng: _toDouble(json['pickupLng']),
      destinationAddress: json['destinationAddress'] ?? '',
      destinationLat: _toDouble(json['destinationLat']),
      destinationLng: _toDouble(json['destinationLng']),
      distanceKm: _toDouble(json['distanceKm']),
      estimatedPrice: _toDouble(json['estimatedPrice']),
      status: json['status'] ?? 'UNKNOWN',
      rating: json['rating'],
      feedback: json['feedback'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
