// core/di/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/token_service.dart';
import '../data/datasources/remote_data_source.dart';
import '../data/datasources/remote_data_source_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/check_auth_status.dart';
import '../domain/usecases/login_user.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/register_user.dart';
import '../domain/entities/auth_state.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';

// HTTP Client
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// SharedPreferences (инициализируется в main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // будет переопределён в main
});

// TokenService
final tokenServiceProvider = Provider<TokenService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TokenService(prefs);
});

// DataSources
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  final client = ref.read(httpClientProvider);
  return RemoteDataSourceImpl(client: client);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

// UseCases
final loginUserProvider = Provider<LoginUser>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return LoginUser(authRepository, tokenService);
});

final logoutUserProvider = Provider<LogoutUser>((ref) {
  final repository = ref.read(authRepositoryProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return LogoutUser(repository, tokenService);
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUser(authRepository);
});

final checkAuthStatusProvider = Provider<CheckAuthStatus>((ref) {
  final tokenService = ref.read(tokenServiceProvider);
  return CheckAuthStatus(tokenService);
});

// ViewModels
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    checkAuthStatus: ref.read(checkAuthStatusProvider),
    loginUser: ref.read(loginUserProvider),
    logoutUser: ref.read(logoutUserProvider),
    registerUser: ref.read(registerUserProvider),
  ),
);
