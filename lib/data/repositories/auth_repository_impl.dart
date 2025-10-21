// data/repositories/auth_repository_impl.dart
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<AuthResponseEntity?> login(String email, String password) async {
    final authResponse = await authRemoteDataSource.login(email, password);
    if (authResponse != null) {
      return authResponse.toEntity();
    }
    return null;
  }

  @override
  Future<bool> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    final res = await authRemoteDataSource.register(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    return res;
  }

  @override
  Future<bool> logout() async {
    return await authRemoteDataSource.logout();
  }
}
