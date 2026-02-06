class LoginRequest {
  final String? phone;
  final String? email;
  final String password;

  LoginRequest({this.phone, this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'password': password,
    };
  }
}
