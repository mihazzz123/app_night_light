// presentation/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../core/utils/token_storage.dart';
import '../../domain/repositories/user_repository.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RegisterUser _registerUser;
  final UserRepository _userRepository;

  AuthViewModel({
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required RegisterUser registerUser,
    required UserRepository userRepository,
  })  : _loginUser = loginUser,
        _logoutUser = logoutUser,
        _registerUser = registerUser,
        _userRepository = userRepository,
        super(AuthState.initial());

  // Метод для проверки статуса авторизации
  Future<void> checkAuthStatus() async {
    try {
      // Не показываем loading если уже в initial состоянии
      if (!state.isLoading) {
        state = AuthState.loading();
      }

      // Проверяем валидность токена
      final hasValidToken = await TokenStorage.hasValidToken();

      if (!hasValidToken) {
        state = AuthState.unauthenticated();
        return;
      }

      // Получаем ID пользователя из токена
      final userId = await TokenStorage.getUserId();

      if (userId == null) {
        state = AuthState.unauthenticated();
        return;
      }

      // Получаем данные пользователя
      final user = await _userRepository.getUserById(userId);

      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        // Пользователь не найден, но токен валиден - очищаем
        await TokenStorage.clearTokens();
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error('Failed to check auth status: $e');
      // В случае ошибки считаем пользователя неавторизованным
      await TokenStorage.clearTokens();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = AuthState.loading();
      final user = await _loginUser(email, password);

      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error('Login failed: Invalid credentials');
      }
    } catch (e) {
      state = AuthState.error('Login error: $e');
      // Очищаем токены в случае ошибки логина
      await TokenStorage.clearTokens();
    }
  }

  Future<void> logout() async {
    try {
      state = AuthState.loading();
      await _logoutUser();
      await TokenStorage.clearTokens();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Logout error: $e');
      // Даже при ошибке очищаем токены и разлогиниваем
      await TokenStorage.clearTokens();
      state = AuthState.unauthenticated();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      state = AuthState.loading();

      // Базовая валидация
      if (password != confirmPassword) {
        state = AuthState.error('Passwords do not match');
        return;
      }

      if (password.length < 6) {
        state = AuthState.error('Password must be at least 6 characters');
        return;
      }

      final success = await _registerUser(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (success) {
        state = AuthState.unauthenticated();
      } else {
        state = AuthState.error('Registration failed');
      }
    } catch (e) {
      state = AuthState.error('Registration error: $e');
    }
  }

  // Метод для очистки ошибок
  void clearError() {
    if (state.hasError) {
      state = AuthState.unauthenticated();
    }
  }

  // Метод для принудительного разлогина (например, при истечении токена)
  Future<void> forceLogout() async {
    await TokenStorage.clearTokens();
    state = AuthState.unauthenticated();
  }
}
