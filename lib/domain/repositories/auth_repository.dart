// domain/repositories/auth_repository.dart
import '../entities/auth_response_entity.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity?> login(String email, String password);
  Future<bool> register(
    String email,
    String password,
    String confirmPassword,
  );
  Future<bool> logout();
}
