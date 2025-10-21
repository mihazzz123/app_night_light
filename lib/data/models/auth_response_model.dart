// data/models/auth_response_model.dart
import '../models/user_model.dart';
import '../../domain/entities/auth_response_entity.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      user: UserModel.fromJson(json['user']),
    );
  }

  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      user: user.toEntity(),
    );
  }
}
