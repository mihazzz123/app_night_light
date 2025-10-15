import 'package:app_night_light/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<UserEntity?> call() => repository.checkAuthStatus();
}
