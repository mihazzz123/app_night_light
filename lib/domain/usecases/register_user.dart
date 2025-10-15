import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.register(email, password);
  }
}
