import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _accessTokenKey = "Access-Token";
  static const String _refreshTokenKey = "Refresh-Token";

  /// Store access token securely
  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token securely
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Store refresh token securely
  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token securely
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Delete access token
  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Delete refresh token
  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Delete all tokens
  static Future<void> deleteAllTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Get access token synchronously (returns empty string if not found)
  /// Note: This is for backward compatibility with existing code
  static Future<String> getAccessTokenSync() async {
    return await getAccessToken() ?? '';
  }

  /// Get refresh token synchronously (returns empty string if not found)
  /// Note: This is for backward compatibility with existing code
  static Future<String> getRefreshTokenSync() async {
    return await getRefreshToken() ?? '';
  }
}

