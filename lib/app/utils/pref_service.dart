import 'package:heimwatt/app/utils/secure_token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  static late SharedPreferences _pref;

  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;
  static bool _tokensLoaded = false;

  static Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
    await _loadTokensFromSecureStorage();
  }

  static Future<void> _loadTokensFromSecureStorage() async {
    _cachedAccessToken = await SecureTokenService.getAccessToken();
    _tokensLoaded = true;
  }

  static const String accessToken = "Access-Token";
  static const String dealId = "dealId";
  static const String contactId = "contactId";

  static const String refreshToken = "Refresh-Token";
  static const String userId = "User-Id";
  static const String dealName = "dealName";

  static Future<void> setValue(String key, value) async {
    if (key == accessToken && value is String) {
      _cachedAccessToken = value;
      await SecureTokenService.setAccessToken(value);
      // Update cache
      return;
    }
    if (key == refreshToken && value is String) {
      _cachedRefreshToken = value;
      await SecureTokenService.setRefreshToken(value);
      return;
    }

    if (value is String) {
      await _pref.setString(key, value);
    } else if (value is int) {
      await _pref.setInt(key, value);
    } else if (value is double) {
      await _pref.setDouble(key, value);
    } else if (value is bool) {
      await _pref.setBool(key, value);
    } else if (value is List<String>) {
      await _pref.setStringList(key, value);
    }
  }

  static String getString(String key) {
    if (key == accessToken) {
      return _cachedAccessToken ?? '';
    }
    if (key == refreshToken) {
      return _cachedRefreshToken ?? '';
    }

    return _pref.getString(key) ?? '';
  }

  static Future<String> getAccessToken() async {
    if (!_tokensLoaded) {
      await _loadTokensFromSecureStorage();
    }
    return _cachedAccessToken ?? '';
  }

  static Future<String> getRefreshToken() async {
    if (!_tokensLoaded) {
      await _loadTokensFromSecureStorage();
    }
    return _cachedRefreshToken ?? '';
  }

  static int getInt(String key) {
    return _pref.getInt(key) ?? 0;
  }

  static double getDouble(String key) {
    return _pref.getDouble(key) ?? 0.0;
  }

  static bool getBool(String key) {
    return _pref.getBool(key) ?? false;
  }

  static List<String> getStringList(String key) {
    return _pref.getStringList(key) ?? [];
  }

  static Future<void> clear() async {
    await _pref.clear();
    await SecureTokenService.deleteAllTokens();
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _tokensLoaded = false;
  }
}
