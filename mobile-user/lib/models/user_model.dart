class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final int? points;
  final String? fcmToken;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.points,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      points: json['points'],
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'points': points,
      'fcmToken': fcmToken,
    };
  }
}
