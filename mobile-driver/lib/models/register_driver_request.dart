class RegisterDriverRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String vehicleType;
  final String vehiclePlate;

  RegisterDriverRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.vehicleType,
    required this.vehiclePlate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
    };
  }
}
