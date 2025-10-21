// data/datasources/user_local_data_source.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import 'dart:convert';

abstract class UserLocalDataSource {
  Future<UserEntity?> getCurrentUser();
  Future<void> saveUser(UserEntity user);
  Future<void> clearUser();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  static const String _userKey = 'current_user';

  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap).toEntity();
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing user from local storage: $e');
        }
        await clearUser(); // Чистим некорректные данные
      }
    }
    return null;
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    final userModel = UserModel(
      id: user.id,
      email: user.email,
      userName: user.userName,
      firstName: user.firstName,
      lastName: user.lastName,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      deletedAt: user.createdAt,
    );
    final userJson = jsonEncode(userModel.toJson());
    await prefs.setString(_userKey, userJson);
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
