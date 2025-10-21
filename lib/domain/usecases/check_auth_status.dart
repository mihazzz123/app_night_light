import 'package:app_night_light/domain/entities/user_entity.dart';
import '../../core/utils/token_storage.dart';
import '../../domain/repositories/user_repository.dart';

class CheckAuthStatus {
  final UserRepository _userRepository;

  CheckAuthStatus(this._userRepository);

  Future<UserEntity?> call() async {
    // Логика проверки статуса аутентификации
    final token = await TokenStorage.getAccessToken();
    if (token != null && !await TokenStorage.isTokenExpired()) {
      final userId = await TokenStorage.getUserId();
      if (userId != null) {
        return await _userRepository.getUserById(userId);
      } else {
        null;
      }
    }
    return null;
  }
}
