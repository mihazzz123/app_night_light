import '../repositories/auth_repository.dart';
import '../../core/utils/token_storage.dart';
import '../../domain/repositories/user_repository.dart';

class LogoutUser {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LogoutUser(this._authRepository, this._userRepository);

  Future<bool> call() async {
    try {
      await _authRepository.logout();
      await TokenStorage.clearTokens();
      await _userRepository.clearUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
