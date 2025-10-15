// presentation/screens/splash_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import '../../core/di/app_providers.dart';

class SplashRouter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    if (authState.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка: ${authState.error}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    ref.read(authViewModelProvider.notifier).checkAuthStatus(),
                child: Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return authState.isAuthorized && authState.user != null
        ? HomeScreen(user: authState.user!)
        : AuthScreen();
  }
}
