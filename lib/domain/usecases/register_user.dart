import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity?> call({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await repository.register(email, password, confirmPassword);
  }
}
