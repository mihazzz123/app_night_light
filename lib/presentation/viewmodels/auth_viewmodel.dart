import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

class AuthViewModel extends StateNotifier<AsyncValue<AuthState>> {
  final CheckAuthStatus checkAuthStatus;

  AuthViewModel(this.checkAuthStatus) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final result = await checkAuthStatus();
    state = AsyncValue.data(result);
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<AuthState>>((ref) {
      // Временно заглушка, пока не подключён DI
      final usecase = CheckAuthStatus(FakeAuthRepository());
      return AuthViewModel(usecase);
    });

// Временная реализация для запуска
class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthState> checkAuthStatus() async {
    return AuthState(isAuthorized: false);
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    return UserEntity(id: '1', email: email);
  }

  @override
  Future<UserEntity> register(String email, String password) async {
    return UserEntity(id: '2', email: email);
  }
}
