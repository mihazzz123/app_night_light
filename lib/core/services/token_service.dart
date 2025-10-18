// core/services/token_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userEmailKey = 'user_email';
  static const String _isFirstLaunchKey = 'is_first_launch';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _preferences;

  TokenService(this._preferences);

  // Сохранение токенов
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _preferences.setString(_userEmailKey, email);
  }

  // Получение access токена
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // Получение refresh токена
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Получение email пользователя
  String? getUserEmail() {
    return _preferences.getString(_userEmailKey);
  }

  // Проверка авторизации
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Выход из системы
  Future<void> logout() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _preferences.remove(_userEmailKey);
  }

  // Проверка первого запуска
  bool get isFirstLaunch {
    return _preferences.getBool(_isFirstLaunchKey) ?? true;
  }

  // Отметить, что приложение уже запускалось
  Future<void> setFirstLaunchCompleted() async {
    await _preferences.setBool(_isFirstLaunchKey, false);
  }
}
