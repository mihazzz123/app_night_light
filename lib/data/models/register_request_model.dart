// data/models/register_request_model.dart
class RegisterRequestModel {
  final String email;
  final String password;
  final String confirmPassword;
  final String userName;

  RegisterRequestModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'user_name': userName,
    };
  }
}
