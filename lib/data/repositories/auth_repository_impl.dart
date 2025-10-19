// data/repositories/auth_repository_impl.dart
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity?> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
    return userModel?.toEntity();
  }

  @override
  Future<UserEntity?> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    final userModel = await remoteDataSource.register(
      email,
      password,
      confirmPassword,
    );
    return userModel?.toEntity();
  }

  @override
  Future<bool> logout() async {
    return await remoteDataSource.logout();
  }
}
