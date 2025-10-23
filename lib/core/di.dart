// core/di/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/user_local_data_source.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/main_state.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/viewmodels/main_viewmodel.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/utils/token_storage.dart';

// Конфигурации
const devConfig = AppConfig(
  baseUrl: 'https://api.m3zold-lab.tech',
  apiVersion: 'v1',
);

const prodConfig = AppConfig(
  baseUrl: 'https://api.m3zold-lab.tech',
  apiVersion: 'v1',
);

// HTTP Client
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// SharedPreferences (инициализируется в main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

// AppConfig
final appConfigProvider = Provider<AppConfig>((ref) {
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  return isProduction ? prodConfig : devConfig;
});

// ApiClient - БЕЗ зависимости от authViewModelProvider
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.read(appConfigProvider);

  return ApiClient(
    baseUrl: config.apiBaseUrl,
    getToken: () => TokenStorage.getAccessToken(),
    // Убираем onTokenExpired чтобы разорвать цикл
  );
});

// DataSources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    apiClient: ref.read(apiClientProvider),
  );
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourceImpl(
    apiClient: ref.read(apiClientProvider),
  );
});

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  return UserLocalDataSourceImpl();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authRemoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDataSource: ref.read(userRemoteDataSourceProvider),
    localDataSource: ref.read(userLocalDataSourceProvider),
  );
});

// UseCases
final checkAuthStatusProvider = Provider<CheckAuthStatus>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return CheckAuthStatus(userRepository);
});

final loginUserProvider = Provider<LoginUser>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  return LoginUser(authRepository, userRepository);
});

final logoutUserProvider = Provider<LogoutUser>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  return LogoutUser(authRepository, userRepository);
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUser(authRepository);
});

// ViewModels
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    loginUser: ref.read(loginUserProvider),
    logoutUser: ref.read(logoutUserProvider),
    registerUser: ref.read(registerUserProvider),
    userRepository: ref.read(userRepositoryProvider),
  ),
);

// Провайдер
final mainViewModelProvider = StateNotifierProvider<MainViewModel, MainState>(
  (ref) => MainViewModel(),
);
