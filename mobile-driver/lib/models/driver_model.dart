class Driver {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? status;
  final String? availability;
  final String? fcmToken;
  final String? simUrl;
  final String? ktpUrl;
  final String? photoUrl;

  Driver({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.vehicleType,
    this.vehiclePlate,
    this.status,
    this.availability,
    this.fcmToken,
    this.simUrl,
    this.ktpUrl,
    this.photoUrl,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      vehicleType: json['vehicleType'],
      vehiclePlate: json['vehiclePlate'],
      status: json['status'],
      availability: json['availability'],
      fcmToken: json['fcmToken'],
      simUrl: json['simUrl'],
      ktpUrl: json['ktpUrl'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'status': status,
      'availability': availability,
      'fcmToken': fcmToken,
      'simUrl': simUrl,
      'ktpUrl': ktpUrl,
      'photoUrl': photoUrl,
    };
  }
}
