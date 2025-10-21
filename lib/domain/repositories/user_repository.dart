import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> getUserById(String userId);
  Future<void> saveUser(UserEntity user);
  Future<void> clearUser();
}
