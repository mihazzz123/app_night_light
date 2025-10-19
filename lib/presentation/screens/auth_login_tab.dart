// presentation/screens/auth_login_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/user_entity.dart';
import 'home_screen.dart';
import 'auth_forgot_password_dialog.dart';

class AuthLoginTab extends ConsumerStatefulWidget {
  const AuthLoginTab({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthLoginTab> createState() => _AuthLoginTabState();
}

class _AuthLoginTabState extends ConsumerState<AuthLoginTab> {
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
    });

    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      await authViewModel.login(
        Validator.normalizeEmail(loginEmailController.text.trim()),
        loginPasswordController.text.trim(),
      );

      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthorized && authState.user != null) {
        _navigateToHome(authState.user!);
      } else if (authState.error != null) {
        _showError(authState.error!);
      }
    } catch (e) {
      _showError('Ошибка при входе: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToHome(UserEntity user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
    );
  }

  void _showError(String message) {
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
        key: _loginFormKey,
        child: Column(
          children: [
            // Логотип
            _buildLogo(colorScheme),
            const SizedBox(height: 24),

            // Заголовок
            Text(
              'Добро пожаловать',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Войдите в свой аккаунт',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 60),
              ),
            ),
            const SizedBox(height: 32),

            // Поле email
            TextFormField(
              controller: loginEmailController,
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

            // Поле пароля
            TextFormField(
              controller: loginPasswordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                hintText: 'Введите ваш пароль',
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
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
                _passwordTouched,
              ),
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                if (!_passwordTouched) {
                  setState(() => _passwordTouched = true);
                }
              },
              onFieldSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 8),

            // Забыли пароль
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (context) =>
                              const AuthForgotPasswordDialog(),
                        ),
                child: const Text('Забыли пароль?'),
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка входа
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
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
                        'Войти',
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
