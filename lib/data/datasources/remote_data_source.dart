import '../models/user_model.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/utils/crypto_utils.dart';

class RemoteDataSource {
  final Dio dio;

  RemoteDataSource(this.dio);

  Future<UserModel> login(String email, String password) async {
    final payload = jsonEncode({'email': email, 'password': password});
    final signature = CryptoUtils.generateSignature(payload);

    final response = await dio.post(
      '/auth/login',
      data: payload,
      options: Options(
        headers: {
          'X-App-Signature': signature,
          'Content-Type': 'application/json',
        },
      ),
    );

    return UserModel.fromJson(response.data);
  }

  Future<UserModel> register(String email, String password) async {
    final payload = jsonEncode({'email': email, 'password': password});
    final signature = CryptoUtils.generateSignature(payload);

    final response = await dio.post(
      '/auth/register',
      data: payload,
      options: Options(
        headers: {
          'X-App-Signature': signature,
          'Content-Type': 'application/json',
        },
      ),
    );

    return UserModel.fromJson(response.data);
  }
}
