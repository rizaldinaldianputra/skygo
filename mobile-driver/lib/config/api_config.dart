class ApiConfig {
  static const String baseUrl = "http://localhost:8081/api";
  static const String loginEndpoint = "$baseUrl/auth/login";
  static const String registerDriverEndpoint = "$baseUrl/auth/drivers/register";
  static const String driverProfileEndpoint = "$baseUrl/drivers/profile";
  static const String trackingUpdateEndpoint =
      "$baseUrl/tracking/update"; // POST
  static const String driverOnlineEndpoint =
      "$baseUrl/tracking/driver/{id}/online"; // POST
  static const String driverOfflineEndpoint =
      "$baseUrl/tracking/driver/{id}/offline"; // POST
}
