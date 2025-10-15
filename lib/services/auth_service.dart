import '../storage/token_storage.dart';

class AuthService {
  // Заглушка: проверка токена
  Future<bool> checkToken() async {
    final token = await TokenStorage.getToken();
    print('Проверка токена: $token');
    return token != null && token.isNotEmpty;
  }

  // Заглушка: вход
  Future<bool> login(String email, String password) async {
    // Эмулируем успешный вход при любом email и пароле
    await TokenStorage.saveToken('mock_token_for_$email');
    return true;
  }

  // Заглушка: регистрация
  Future<bool> register(String email, String password) async {
    // Эмулируем успешную регистрацию
    await TokenStorage.saveToken('mock_token_for_$email');
    return true;
  }

  // Заглушка: выход
  Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}
