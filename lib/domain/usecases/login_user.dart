import 'package:app_night_light/core/services/token_service.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;
  final TokenService tokenService;

  LoginUser(this.repository, this.tokenService);

  Future<UserEntity?> call(String email, String password) async {
    final user = await repository.login(email, password);

    if (user != null && user.accessToken != null && user.refreshToken != null) {
      await tokenService.saveTokens(
        accessToken: user.accessToken!,
        refreshToken: user.refreshToken!,
        email: user.email,
      );
    }

    return user;
  }
}
