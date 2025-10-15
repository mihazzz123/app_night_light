import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_data_source.dart';
import '../models/user_model.dart';

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
    String name,
  ) async {
    final userModel = await remoteDataSource.register(email, password, name);
    return userModel?.toEntity();
  }

  @override
  Future<bool> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Future<UserEntity?> checkAuthStatus() async {
    final userModel = await remoteDataSource.checkAuthStatus();
    return userModel?.toEntity();
  }
}
