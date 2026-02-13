class User {
  final int id;
  final String name;
  final String? phone;
  final String email;

  User({required this.id, required this.name, this.phone, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class Order {
  final int id;
  final int userId;
  final User? user;
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
    this.user,
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
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      driverId: json['driver'] != null
          ? json['driver']['id']
          : null, // Handle null driver object or id
      pickupAddress: json['pickupAddress'],
      pickupLat: json['pickupLat'],
      pickupLng: json['pickupLng'],
      destinationAddress: json['destinationAddress'],
      destinationLat: json['destinationLat'],
      destinationLng: json['destinationLng'],
      distanceKm: (json['distanceKm'] is int)
          ? (json['distanceKm'] as int).toDouble()
          : json['distanceKm'],
      estimatedPrice: (json['estimatedPrice'] is int)
          ? (json['estimatedPrice'] as int).toDouble()
          : json['estimatedPrice'],
      status: json['status'],
      rating: json['rating'],
      feedback: json['feedback'],
      createdAt: json['createdAt'],
    );
  }
}
