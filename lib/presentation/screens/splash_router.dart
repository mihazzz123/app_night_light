// presentation/screens/splash_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'auth_screen.dart';
import '../../core/di/app_providers.dart';

class SplashRouter extends ConsumerWidget {
  const SplashRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    if (authState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка: ${authState.error}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    ref.read(authViewModelProvider.notifier).checkAuthStatus(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return authState.isAuthorized && authState.user != null
        ? HomeScreen(user: authState.user!)
        : const AuthScreen();
  }
}
