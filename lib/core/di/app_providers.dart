// core/di/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/remote_data_source.dart';
import '../../data/datasources/remote_data_source_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/auth_state.dart';

// HTTP Client
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

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
  return LoginUser(authRepository);
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUser(authRepository);
});

final checkAuthStatusProvider = Provider<CheckAuthStatus>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return CheckAuthStatus(authRepository);
});

// ViewModels
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    ref.read(checkAuthStatusProvider),
    ref.read(loginUserProvider),
    ref.read(registerUserProvider),
  ),
);
