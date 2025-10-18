import '../core/utils/token_storage.dart';

class AuthService {
  // Проверка наличия валидного токена
  Future<bool> checkToken() async {
    final hasValidToken = await TokenStorage.hasValidToken();
    print('Проверка токена: $hasValidToken');
    return hasValidToken;
  }

  // Заглушка: вход
  Future<bool> login(String email, String password) async {
    // Эмулируем успешный вход при любом email и пароле
    await TokenStorage.saveTokens(
      accessToken: 'mock_access_token_for_$email',
      refreshToken: 'mock_refresh_token_for_$email',
      expiresIn: 900, // 15 минут
      userId: 'mock_user_id_$email',
    );
    return true;
  }

  // Заглушка: регистрация
  Future<bool> register(String email, String password) async {
    // Эмулируем успешную регистрацию
    await TokenStorage.saveTokens(
      accessToken: 'mock_access_token_for_$email',
      refreshToken: 'mock_refresh_token_for_$email',
      expiresIn: 900, // 15 минут
      userId: 'mock_user_id_$email',
    );
    return true;
  }

  // Заглушка: выход
  Future<void> logout() async {
    await TokenStorage.clearTokens();
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
