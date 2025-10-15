import '../datasources/remote_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_state.dart';
import '../../core/utils/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<UserEntity> login(String email, String password) async {
    final model = await remote.login(email, password);
    return UserEntity(id: model.id, email: model.email);
  }

  @override
  Future<AuthState> checkAuthStatus() async {
    // Проверка токена из хранилища
    final token = await TokenStorage.getToken();
    if (token == null) return AuthState(isAuthorized: false);

    // TODO: проверить токен на сервере
    return AuthState(
      isAuthorized: true,
      user: UserEntity(id: '123', email: 'test@example.com'),
    );
  }

  @override
  Future<UserEntity> register(String email, String password) async {
    final model = await remote.register(email, password);
    return UserEntity(id: model.id, email: model.email);
  }
}
