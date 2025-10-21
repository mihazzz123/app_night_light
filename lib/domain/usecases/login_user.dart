import '../entities/user_entity.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/utils/token_storage.dart';
import '../../domain/repositories/user_repository.dart';

class LoginUser {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LoginUser(this._authRepository, this._userRepository);

  Future<UserEntity?> call(String email, String password) async {
    final AuthResponseEntity? loginResponse =
        await _authRepository.login(email, password);

    if (loginResponse != null) {
      // Конвертируем expiresIn (секунды) в DateTime
      final expiryTime = DateTime.now().add(
        Duration(seconds: loginResponse.expiresIn),
      );

      // Сохраняем токены из AuthResponseEntity
      await TokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        expiresIn: expiryTime, // Теперь передаем DateTime
        userId: loginResponse.user.id,
      );

      // Сохраняем пользователя
      await _userRepository.saveUser(loginResponse.user);

      return loginResponse.user;
    }

    return null;
  }
}
