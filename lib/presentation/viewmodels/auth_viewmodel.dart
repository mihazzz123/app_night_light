// presentation/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final CheckAuthStatus _checkAuthStatus;
  final LoginUser _loginName;
  final RegisterUser _registerUser;

  AuthViewModel(this._checkAuthStatus, this._loginName, this._registerUser)
    : super(AuthState.initial()) {
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
      final user = await _loginName(email, password);
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error('Ошибка авторизации');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
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

  void logout() {
    state = AuthState.unauthenticated();
    // Здесь можно добавить вызов logout из репозитория
  }
}
