// domain/entities/auth_state.dart
import 'user_entity.dart';

enum AuthStatus {
  initial, // начальная
  loading, // загрузка
  authenticated, // аутентифицировано
  unauthenticated, // неаутентифицировано
  error, // ошибка
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthorized => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error && error != null;

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(UserEntity user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated, user: null);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, error: message);

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}
