// data/models/register_response_model.dart
class RegisterResponseModel {
  final String id;
  final String email;
  final String userName;
  final String firstName;
  final String lastName;
  final bool isActive;

  RegisterResponseModel({
    required this.id,
    required this.email,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.isActive,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}
