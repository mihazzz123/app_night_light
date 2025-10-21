// data/datasources/user_remote_data_source.dart
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/network/api_client.dart';

abstract class UserRemoteDataSource {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> getUserById(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserEntity?> getCurrentUser() async {
    final response = await apiClient.get('/api/user/me');
    if (response.success) {
      return UserModel.fromJson(response.data).toEntity();
    }
    return null;
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    final response = await apiClient.get('/api/user/$userId');
    if (response.success) {
      return UserModel.fromJson(response.data).toEntity();
    }
    return null;
  }
}
