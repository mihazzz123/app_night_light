// data/datasources/remote_data_source_impl.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'remote_data_source.dart';
import '../models/user_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

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
        return UserModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Неверный email или пароль');
      } else {
        throw Exception('Ошибка авторизации: ${response.statusCode}');
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
      userName: email.split('@').first, // Генерируем userName из email
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
    // TODO: Реализовать logout с API
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    // TODO: Реализовать проверку авторизации с API
    await Future.delayed(Duration(seconds: 1));
    return null;
  }
}
