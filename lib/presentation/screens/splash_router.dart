// presentation/screens/splash_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'auth_screen.dart';
import '../../core/di.dart';

class SplashRouter extends ConsumerStatefulWidget {
  const SplashRouter({super.key});

  @override
  ConsumerState<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends ConsumerState<SplashRouter> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authViewModelProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
