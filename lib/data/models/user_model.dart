// data/models/user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required String id, required String email, required String name})
    : super(id: id, email: email, name: name);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name};
  }

  UserEntity toEntity() {
    return UserEntity(id: id, email: email, name: name);
  }
}
