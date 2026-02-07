class KeycloakConfig {
  static const String clientId = "skygo-mobile-user";
  static const String redirectUrl = "com.skycosmic.skygo://login-callback";
  static const String issuer = "http://10.0.2.2:8080/realms/skygo";
  static const String discoveryUrl = "$issuer/.well-known/openid-configuration";
  static const String authorizationEndpoint =
      "$issuer/protocol/openid-connect/auth";
  static const String tokenEndpoint = "$issuer/protocol/openid-connect/token";
  static const String endSessionEndpoint =
      "$issuer/protocol/openid-connect/logout";
}
