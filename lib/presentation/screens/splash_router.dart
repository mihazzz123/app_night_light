// presentation/screens/splash_router.dart
import 'package:flutter/foundation.dart';
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
  bool _initialCheckCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performInitialAuthCheck();
    });
  }

  Future<void> _performInitialAuthCheck() async {
    final authNotifier = ref.read(authViewModelProvider.notifier);

    try {
      await authNotifier.checkAuthStatus();
    } catch (e) {
      // Ошибка уже будет обработана в состоянии AuthState
      if (kDebugMode) {
        print('Initial auth check error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _initialCheckCompleted = true;
        });
      }
    }
  }

  void _retryAuthCheck() {
    ref.read(authViewModelProvider.notifier).checkAuthStatus();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Проверка авторизации...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Ошибка',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _retryAuthCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Повторить'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Продолжить без авторизации
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    }
                  },
                  child: const Text('Перейти к авторизации'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Показываем загрузку только при первоначальной проверке
    if (!_initialCheckCompleted && authState.isLoading) {
      return _buildLoadingScreen();
    }

    // Если есть ошибка и это не первоначальная загрузка
    if (authState.hasError && _initialCheckCompleted) {
      return _buildErrorScreen(authState.error!);
    }

    // Если пользователь авторизован - показываем главный экран
    if (authState.isAuthorized && authState.user != null) {
      return HomeScreen(user: authState.user!);
    }

    // Во всех остальных случаях показываем экран авторизации
    // Это включает случаи:
    // - Первоначальная проверка завершена, пользователь не авторизован
    // - Статус unauthenticated
    // - Любые другие статусы кроме loading и error
    return const AuthScreen();
  }
}
