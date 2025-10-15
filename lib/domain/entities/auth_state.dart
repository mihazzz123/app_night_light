import 'user_entity.dart';

class AuthState {
  final bool isAuthorized;
  final UserEntity? user;

  AuthState({required this.isAuthorized, this.user});
}
