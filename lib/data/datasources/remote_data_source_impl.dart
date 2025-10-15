// data/datasources/remote_data_source_impl.dart
import 'remote_data_source.dart';
import '../models/user_model.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  // Временная реализация для тестирования
  final Map<String, String> _mockUsers = {'test@test.com': 'password123'};

  final Map<String, UserModel> _userData = {
    'test@test.com': UserModel(
      id: '1',
      email: 'test@test.com',
      name: 'Test User',
    ),
  };

  @override
  Future<UserModel?> login(String email, String password) async {
    // Имитация задержки сети
    await Future.delayed(Duration(seconds: 1));

    if (_mockUsers[email] == password) {
      return _userData[email];
    }
    return null;
  }

  @override
  Future<UserModel?> register(
    String email,
    String password,
    String name,
  ) async {
    // Имитация задержки сети
    await Future.delayed(Duration(seconds: 1));

    // Проверяем, нет ли уже пользователя с таким email
    if (_mockUsers.containsKey(email)) {
      throw Exception('Пользователь с таким email уже существует');
    }

    // Создаем нового пользователя
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
    );

    // Сохраняем в "базу данных"
    _mockUsers[email] = password;
    _userData[email] = newUser;

    return newUser;
  }

  @override
  Future<bool> logout() async {
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    // Имитация проверки авторизации
    // В реальном приложении здесь бы проверялся токен
    await Future.delayed(Duration(seconds: 1));

    // Для тестирования возвращаем null (не авторизован)
    // Чтобы всегда видеть экран логина
    return null;

    // Если хотите сразу переходить на главный экран, раскомментируйте:
    // return _userData['test@test.com'];
  }
}
