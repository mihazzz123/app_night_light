import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_state.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<AuthState> checkAuthStatus();
  Future<UserEntity> register(String email, String password);
}
