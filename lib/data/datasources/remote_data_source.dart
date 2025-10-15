import '../models/user_model.dart';

abstract class RemoteDataSource {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String email, String password, String name);
  Future<bool> logout();
  Future<UserModel?> checkAuthStatus();
}
