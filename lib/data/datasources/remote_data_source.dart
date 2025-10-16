// data/datasources/remote_data_source.dart
import '../models/user_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

abstract class RemoteDataSource {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String email, String password, String name);
  Future<RegisterResponseModel?> registerWithApi(RegisterRequestModel request);
  Future<bool> logout();
  Future<UserModel?> checkAuthStatus();
}
