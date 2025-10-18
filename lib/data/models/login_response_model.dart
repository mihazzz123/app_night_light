// data/models/login_response_model.dart
class LoginResponseModel {
  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final String userName;
  final String email;

  LoginResponseModel({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.userName,
    required this.email,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LoginResponseModel(
      accessToken: data['access_token']?.toString() ?? '',
      expiresIn: data['expires_in'] ?? 0,
      refreshToken: data['refresh_token']?.toString() ?? '',
      tokenType: data['token_type']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      userName: data['user_name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
    );
  }
}
