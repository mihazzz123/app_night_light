// domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;
  final String userName;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.userName,
    this.firstName,
    this.lastName,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Дополнительные полезные методы
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return userName;
    }
  }

  bool get hasProfileInfo => firstName != null || lastName != null;

  UserEntity copyWith({
    String? id,
    String? email,
    String? userName,
    String? firstName,
    String? lastName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
