import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/entities/auth_state.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

final dioProvider = Provider(
  (ref) => Dio(BaseOptions(baseUrl: 'https://api.m3zold-lab.tech')),
);

final remoteDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return RemoteDataSource(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(remoteDataSourceProvider);
  return AuthRepositoryImpl(remote);
});

final checkAuthStatusProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CheckAuthStatus(repo);
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<AuthState>>((ref) {
      final usecase = ref.watch(checkAuthStatusProvider);
      return AuthViewModel(usecase);
    });

final loginUserProvider = Provider<LoginUser>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUser(repo);
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RegisterUser(repo);
});
