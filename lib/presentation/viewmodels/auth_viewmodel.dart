// presentation/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final CheckAuthStatus _checkAuthStatus;
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RegisterUser _registerUser;

  AuthViewModel({
    required CheckAuthStatus checkAuthStatus,
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required RegisterUser registerUser,
  })  : _checkAuthStatus = checkAuthStatus,
        _loginUser = loginUser,
        _logoutUser = logoutUser,
        _registerUser = registerUser,
        super(AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = AuthState.loading();
    try {
      final user = await _checkAuthStatus();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _loginUser(email, password);
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error('Ошибка авторизации');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register(
      String email, String password, String confirmPassword) async {
    state = AuthState.loading();
    try {
      final user = await _registerUser(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error('Ошибка регистрации');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    try {
      final res = await _logoutUser();
      if (res) {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}
