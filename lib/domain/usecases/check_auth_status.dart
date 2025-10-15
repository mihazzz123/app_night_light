import '../entities/auth_state.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<AuthState> call() => repository.checkAuthStatus();
}
