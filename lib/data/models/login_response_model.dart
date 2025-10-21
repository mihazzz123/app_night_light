// data/models/login_response_model.dart
import '../models/user_model.dart';

class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final DateTime expiresIn;
  final UserModel user;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? {};

    return LoginResponseModel(
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
      expiresIn: _parseExpiresIn(json['expires_in']),
      user: UserModel.fromJson(userData),
    );
  }

  static DateTime _parseExpiresIn(dynamic expiresIn) {
    if (expiresIn is int) {
      return DateTime.now().add(Duration(seconds: expiresIn));
    } else if (expiresIn is String) {
      return DateTime.tryParse(expiresIn) ?? DateTime.now();
    } else {
      return DateTime.now().add(const Duration(hours: 1));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn.millisecondsSinceEpoch ~/ 1000,
      'user': user.toJson(),
    };
  }
}
