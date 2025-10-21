// domain/entities/auth_response_entity.dart
import '../entities/user_entity.dart';

class AuthResponseEntity {
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // в секундах
  final UserEntity user;

  AuthResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });
}
