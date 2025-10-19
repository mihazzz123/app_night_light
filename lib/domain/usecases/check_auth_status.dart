import 'package:app_night_light/core/services/token_service.dart';
import 'package:app_night_light/domain/entities/user_entity.dart';

class CheckAuthStatus {
  final TokenService tokenService;

  CheckAuthStatus(this.tokenService);

  Future<UserEntity?> call() async {
    final token = await tokenService.getAccessToken();
    final email = tokenService.getUserEmail();

    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return null;
    }

    return UserEntity(
      id: '', // можно добавить в TokenService, если нужно
      email: email,
      userName: '',
      firstName: '',
      lastName: '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      accessToken: token,
      refreshToken: await tokenService.getRefreshToken(),
    );
  }
}
