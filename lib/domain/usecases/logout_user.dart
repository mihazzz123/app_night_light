import 'package:app_night_light/core/services/token_service.dart';
import '../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository repository;
  final TokenService tokenService;

  LogoutUser(this.repository, this.tokenService);

  Future<bool> call() async {
    final success = await repository.logout();
    if (success) {
      await tokenService.logout(); // удаляет токены и email
    }
    return success;
  }
}
