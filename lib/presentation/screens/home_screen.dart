import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/di.dart';
import 'auth_screen.dart';

class HomeScreen extends ConsumerWidget {
  // Изменено на ConsumerWidget
  final UserEntity user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    if (authState.isAuthorized && authState.user != null) {
      return const AuthScreen();
    }

    // Добавлен WidgetRef
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Главная',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Логотип
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.nightlight_round,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Приветствие
                Text(
                  'Добро пожаловать!',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),

                // Информация о пользователе
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceVariant,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildUserInfoRow(
                          'Имя пользователя',
                          user.userName,
                          colorScheme,
                          textTheme,
                        ),
                        _buildUserInfoRow(
                          'Email',
                          user.email,
                          colorScheme,
                          textTheme,
                        ),
                        _buildUserInfoRow(
                          'Полное имя',
                          '${user.firstName} ${user.lastName}',
                          colorScheme,
                          textTheme,
                        ),
                        _buildUserInfoRow(
                          'Статус',
                          user.isActive ? 'Активен' : 'Неактивен',
                          colorScheme,
                          textTheme,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Кнопка выхода
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logout(context, ref),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: colorScheme.error,
                    ),
                    child: Text(
                      'Выйти',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(
    String label,
    String value,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      await authViewModel.logout();

      // Навигация на экран авторизации
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка при выходе: $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
