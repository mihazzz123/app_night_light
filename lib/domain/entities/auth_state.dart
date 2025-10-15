// domain/entities/auth_state.dart
import 'user_entity.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthorized;
  final UserEntity? user;
  final String? error;

  const AuthState({
    required this.isLoading,
    required this.isAuthorized,
    this.user,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isLoading: true,
      isAuthorized: false,
      user: null,
      error: null,
    );
  }

  factory AuthState.loading() {
    return AuthState(
      isLoading: true,
      isAuthorized: false,
      user: null,
      error: null,
    );
  }

  factory AuthState.authenticated(UserEntity user) {
    return AuthState(
      isLoading: false,
      isAuthorized: true,
      user: user,
      error: null,
    );
  }

  factory AuthState.unauthenticated() {
    return AuthState(
      isLoading: false,
      isAuthorized: false,
      user: null,
      error: null,
    );
  }

  factory AuthState.error(String error) {
    return AuthState(
      isLoading: false,
      isAuthorized: false,
      user: null,
      error: error,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthorized,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}
