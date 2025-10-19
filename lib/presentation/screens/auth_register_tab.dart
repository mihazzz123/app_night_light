import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/auth_state.dart';
import 'auth_screen.dart';

class AuthRegisterTab extends ConsumerStatefulWidget {
  const AuthRegisterTab({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthRegisterTab> createState() => _AuthRegisterTabState();
}

class _AuthRegisterTabState extends ConsumerState<AuthRegisterTab> {
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;
  Timer? _autoNavigateTimer;

  @override
  void dispose() {
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    _autoNavigateTimer?.cancel(); // Важно: отменяем таймер при dispose
    super.dispose();
  }

  Future<void> _register() async {
    final authViewModel = ref.read(authViewModelProvider.notifier);

    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
      _confirmPasswordTouched = true;
    });

    if (!_registerFormKey.currentState!.validate()) return;

    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text.trim();
    final confirmPassword = registerConfirmPasswordController.text.trim();

    if (password != confirmPassword) {
      if (mounted) _showError('Пароли не совпадают');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authViewModel.register(
        Validator.normalizeEmail(email),
        password,
        confirmPassword,
      );

      if (!mounted) return;

      final authState = ref.read(authViewModelProvider);

      if (authState.status == AuthStatus.unauthenticated) {
        _showSuccess();
        _clearForm();

        _startAutoNavigateTimer();
      } else if (authState.hasError) {
        _showError(authState.error!);
      }
    } catch (e) {
      if (mounted) _showError('Ошибка при регистрации: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAutoNavigateTimer() {
    // Отменяем предыдущий таймер, если он был
    _autoNavigateTimer?.cancel();

    // Создаем новый таймер на 5 секунд
    _autoNavigateTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  void _clearForm() {
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    setState(() {
      _emailTouched = false;
      _passwordTouched = false;
      _confirmPasswordTouched = false;
    });
    _registerFormKey.currentState?.reset();
  }

  void _navigateToLogin() {
    if (!mounted) return;

    // Отменяем таймер, если он еще активен
    _autoNavigateTimer?.cancel();

    // Закрываем текущий snackbar если открыт
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(),
      ),
    );
  }

  void _showSuccess() {
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Регистрация прошла успешно!',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Подтвердите регистрацию через письмо на почте.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 90),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Автоматический переход через 5 секунд...',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 80),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 6), // Немного больше чем таймер
        action: SnackBarAction(
          label: 'Войти сейчас',
          textColor: colorScheme.onPrimary,
          onPressed: _navigateToLogin,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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

  String? _validateField(
    String? value,
    String? Function(String?) validator,
    bool touched,
  ) {
    return touched ? validator(value) : null;
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            _buildLogo(colorScheme),
            const SizedBox(height: 24),
            Text(
              'Создайте аккаунт',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Заполните данные для регистрации',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: registerEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'example@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => _validateField(
                value,
                Validator.validateEmail,
                _emailTouched,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (!_emailTouched) {
                  setState(() => _emailTouched = true);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: registerPasswordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                hintText: 'Минимум 8 символов',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) => _validateField(
                value,
                Validator.validatePassword,
                _passwordTouched,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (!_passwordTouched) {
                  setState(() => _passwordTouched = true);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: registerConfirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                hintText: 'Повторите пароль',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) => _validateField(
                value,
                (value) => Validator.validatePassword(
                  value,
                  confirmPassword: registerPasswordController.text,
                ),
                _confirmPasswordTouched,
              ),
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                if (!_confirmPasswordTouched) {
                  setState(() => _confirmPasswordTouched = true);
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'Зарегистрироваться',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
