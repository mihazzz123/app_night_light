// data/datasources/remote_data_source_impl.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'remote_data_source.dart';
import '../models/user_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/login_response_model.dart';
import '../../core/utils/token_storage.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  static const String _baseUrl = 'https://api.m3zold-lab.tech';

  final http.Client client;

  RemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/login');

      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final loginResponse = LoginResponseModel.fromJson(responseData);

        // Сохраняем токены
        await TokenStorage.saveTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          expiresIn: loginResponse.expiresIn,
          userId: loginResponse.userId,
        );

        // Создаем UserModel из данных токена
        return UserModel(
          id: loginResponse.userId,
          email: loginResponse.email,
          userName: loginResponse.userName,
          firstName: '', // Эти данные могут приходить из другого endpoint
          lastName: '',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else if (response.statusCode == 401) {
        throw Exception('Неверный email или пароль');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Ошибка авторизации: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Ошибка сети: $e');
    } on FormatException catch (e) {
      throw Exception('Ошибка формата данных: $e');
    } on TimeoutException catch (e) {
      throw Exception('Таймаут соединения: $e');
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  @override
  Future<UserModel?> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    final request = RegisterRequestModel(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      userName: email.split('@').first,
    );

    final response = await registerWithApi(request);

    if (response != null) {
      return UserModel(
        id: response.id,
        email: response.email,
        userName: response.userName,
        firstName: response.firstName,
        lastName: response.lastName,
        isActive: response.isActive,
        createdAt: response.createdAt,
        updatedAt: response.updatedAt,
      );
    }

    return null;
  }

  @override
  Future<RegisterResponseModel?> registerWithApi(
    RegisterRequestModel request,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/register');

      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return RegisterResponseModel.fromJson(responseData);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Ошибка регистрации');
      } else if (response.statusCode == 409) {
        throw Exception('Пользователь с таким email уже существует');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Ошибка сервера: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Ошибка сети: $e');
    } on FormatException catch (e) {
      throw Exception('Ошибка формата данных: $e');
    } on TimeoutException catch (e) {
      throw Exception('Таймаут соединения: $e');
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        // Если токена нет, просто очищаем хранилище
        await TokenStorage.clearTokens();
        return true;
      }

      final url = Uri.parse('$_baseUrl/api/auth/logout');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      // Независимо от ответа сервера, очищаем токены локально
      await TokenStorage.clearTokens();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Даже если сервер вернул ошибку, считаем что выход выполнен
        return true;
      }
    } catch (e) {
      // В случае любой ошибки все равно очищаем токены
      await TokenStorage.clearTokens();
      return true;
    }
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        return null;
      }

      final url = Uri.parse('$_baseUrl/api/auth/me');

      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return UserModel.fromJson(responseData);
      } else {
        // Если токен невалиден, очищаем его
        await TokenStorage.clearTokens();
        return null;
      }
    } catch (e) {
      // В случае ошибки считаем пользователя неавторизованным
      return null;
    }
  }

  // Вспомогательный метод для обновления токена
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final url = Uri.parse('$_baseUrl/auth/refresh');

      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final loginResponse = LoginResponseModel.fromJson(responseData);

        await TokenStorage.saveTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          expiresIn: loginResponse.expiresIn,
          userId: loginResponse.userId,
        );
        return true;
      } else {
        await TokenStorage.clearTokens();
        return false;
      }
    } catch (e) {
      await TokenStorage.clearTokens();
      return false;
    }
  }
}
