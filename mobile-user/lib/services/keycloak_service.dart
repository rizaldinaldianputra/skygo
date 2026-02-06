import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/keycloak_config.dart';

class KeycloakService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> login() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              KeycloakConfig.clientId,
              KeycloakConfig.redirectUrl,
              issuer: KeycloakConfig.issuer,
              serviceConfiguration: const AuthorizationServiceConfiguration(
                authorizationEndpoint: KeycloakConfig.authorizationEndpoint,
                tokenEndpoint: KeycloakConfig.tokenEndpoint,
                endSessionEndpoint: KeycloakConfig.endSessionEndpoint,
              ),
              scopes: ['openid', 'profile', 'email', 'offline_access'],
            ),
          );

      if (result != null && result.accessToken != null) {
        await _secureStorage.write(
          key: 'access_token',
          value: result.accessToken,
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: result.refreshToken,
        );
        await _secureStorage.write(
          key: 'id_token',
          value: result.idToken,
        ); // Contains user info
        return result.accessToken;
      }
      return null;
    } catch (e) {
      print("Keycloak Login Error: $e");
      return null; // Handle error gracefully
    }
  }

  Future<void> logout() async {
    try {
      // Typically need to call end session endpoint, but often just clearing local token is enough for mobile
      // For full logout:
      /*
      await _appAuth.endSession(EndSessionRequest(
          idTokenHint: await _secureStorage.read(key: 'id_token'),
          postLogoutRedirectUrl: KeycloakConfig.redirectUrl,
          serviceConfiguration: const AuthorizationServiceConfiguration(...)
      ));
      */
      await _secureStorage.deleteAll();
    } catch (e) {
      print("Logout error: $e");
    }
  }
}
