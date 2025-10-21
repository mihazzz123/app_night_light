// data/datasources/auth_remote_data_source.dart
import 'dart:async';
import '../models/login_response_model.dart';
import '../../core/utils/token_storage.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/register_request_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel?> login(String email, String password);
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
  });
  Future<bool> logout();
  Future<bool> refreshToken();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel?> login(String email, String password) async {
    final response = await apiClient.post<LoginResponseModel>(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      fromJsonT: (json) => LoginResponseModel.fromJson(json),
    );

    final user = UserModel(
      id: response.data!.user.id,
      email: response.data!.user.email,
      userName: response.data!.user.userName,
      firstName: response.data!.user.firstName,
      lastName: response.data!.user.lastName,
      isActive: response.data!.user.isActive,
      createdAt: response.data!.user.createdAt,
      updatedAt: response.data!.user.updatedAt,
      deletedAt: response.data!.user.deletedAt,
    );

    if (response.hasData && response.isSuccess) {
      return AuthResponseModel(
        accessToken: response.data!.accessToken,
        refreshToken: response.data!.refreshToken,
        expiresIn: response.data!.expiresIn.millisecondsSinceEpoch,
        user: user,
      );
    }

    return null;
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final req = RegisterRequestModel(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      userName: email.split('@').first,
    );

    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      body: req.toJson(),
    );

    return response.isSuccess;
  }

  @override
  Future<bool> logout() async {
    final response = await apiClient.post<Map<String, dynamic>>('/auth/logout');
    return response.isSuccess;
  }

  @override
  Future<bool> refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/refresh',
      body: {
        'refresh_token': refreshToken,
      },
    );

    if (response.hasData && response.isSuccess) {
      final loginResponse = LoginResponseModel.fromJson(response.data!);
      await TokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        expiresIn: loginResponse.expiresIn,
        userId: loginResponse.user.id,
      );
      return true;
    }
    return false;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/user/me',
    );

    if (response.hasData && response.isSuccess) {
      return UserModel.fromJson(response.data!);
    }
    return null;
  }
}
