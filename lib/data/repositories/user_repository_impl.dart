// data/repositories/user_repository_impl.dart
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // Сначала пробуем получить из локального хранилища
      final localUser = await localDataSource.getCurrentUser();
      if (localUser != null) {
        return localUser;
      }

      // Если нет локально, запрашиваем с сервера
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.saveUser(remoteUser);
      }
      return remoteUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user: $e');
      }
      return null;
    }
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      // Сначала проверяем локальное хранилище
      final localUser = await localDataSource.getCurrentUser();
      if (localUser != null && localUser.id == userId) {
        return localUser;
      }

      // Если нет или userId не совпадает, запрашиваем с сервера
      final remoteUser = await remoteDataSource.getUserById(userId);
      if (remoteUser != null) {
        await localDataSource.saveUser(remoteUser);
      }
      return remoteUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user by id: $e');
      }
      return null;
    }
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    await localDataSource.saveUser(user);
  }

  @override
  Future<void> clearUser() async {
    await localDataSource.clearUser();
  }
}
