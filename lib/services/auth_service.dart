import 'package:flutter/foundation.dart';

import '../core/utils/token_storage.dart';

class AuthService {
  // Проверка наличия валидного токена
  Future<bool> checkToken() async {
    final hasValidToken = await TokenStorage.hasValidToken();
    if (kDebugMode) {
      print('Проверка токена: $hasValidToken');
    }
    return hasValidToken;
  }

  // Получение access token
  Future<String?> getAccessToken() async {
    return await TokenStorage.getAccessToken();
  }

  // Получение user ID
  Future<String?> getUserId() async {
    return await TokenStorage.getUserId();
  }
}
