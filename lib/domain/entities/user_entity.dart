// domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;
  final String userName;
  final String firstName;
  final String lastName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? accessToken;
  final String? refreshToken;

  UserEntity({
    required this.id,
    required this.email,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.accessToken,
    this.refreshToken,
  });

  String get fullName => '$firstName $lastName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.userName == userName;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ userName.hashCode;

  factory UserEntity.fromLocalStorage({
    required String email,
    required String accessToken,
    String? refreshToken,
  }) {
    return UserEntity(
      id: 'local',
      email: email,
      userName: 'local',
      firstName: 'Local',
      lastName: 'User',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
