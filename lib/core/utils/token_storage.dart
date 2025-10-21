// core/utils/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresIn, // Теперь это DateTime, а не int
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);

    // Сохраняем timestamp истечения токена
    await prefs.setInt(_tokenExpiryKey, expiresIn.millisecondsSinceEpoch);

    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);

    // Проверяем, не истек ли токен
    if (token != null && expiryTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now < expiryTimestamp) {
        return token;
      } else {
        // Токен истек, удаляем его
        await clearTokens();
        return null;
      }
    }
    return null;
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null;
  }

  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);
    return expiryTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(expiryTimestamp)
        : null;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_userIdKey);
  }

  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  static Future<int?> getSecondsUntilExpiry() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return null;

    final now = DateTime.now();
    final difference = expiry.difference(now);
    return difference.inSeconds;
  }
}
