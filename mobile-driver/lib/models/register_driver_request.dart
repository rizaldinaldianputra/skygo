import 'dart:io';

class RegisterDriverRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String vehicleType;
  final String vehiclePlate;
  final String ktpNumber;
  final String simNumber;
  final File ktpImage;
  final File simImage;

  RegisterDriverRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.ktpNumber,
    required this.simNumber,
    required this.ktpImage,
    required this.simImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'ktpNumber': ktpNumber,
      'simNumber': simNumber,
    };
  }
}
