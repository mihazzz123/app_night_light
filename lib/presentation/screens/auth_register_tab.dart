// presentation/screens/auth_register_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/user_entity.dart';
import 'home_screen.dart';

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

  @override
  void dispose() {
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
      _confirmPasswordTouched = true;
    });

    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text.trim();
    final confirmPassword = registerConfirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showError('Пароли не совпадают');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      await authViewModel.register(
        Validator.normalizeEmail(email),
        password,
        confirmPassword,
      );

      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthorized && authState.user != null) {
        _navigateToLogin(authState.user!);
      } else if (authState.error != null) {
        _showError(authState.error!);
      }
    } catch (e) {
      _showError('Ошибка при регистрации: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToLogin(UserEntity user) {
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
        key: _registerFormKey,
        child: Column(
          children: [
            // Логотип
            _buildLogo(colorScheme),
            const SizedBox(height: 24),

            // Заголовок
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

            // Поле email
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

            // Поле пароля
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

            // Подтверждение пароля
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

            // Кнопка регистрации
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
