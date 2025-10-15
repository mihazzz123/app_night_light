import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity?> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return await repository.register(email, password, name);
  }
}
