// presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/app_providers.dart';
import '../../core/utils/email_validator.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Переменные для отслеживания touched состояний полей
  bool _emailTouched = false;
  bool _passwordTouched = false;

  // Переменная для отслеживания попытки отправки формы
  bool _formSubmitted = false;

  Future<void> _login() async {
    // Помечаем форму как отправленную для подсветки ошибок
    setState(() {
      _formSubmitted = true;
      _emailTouched = true;
      _passwordTouched = true;
    });

    // Базовая валидация
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Пожалуйста, заполните все поля');
      return;
    }

    // Детальная валидация формы
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      await authViewModel.login(EmailValidator.normalize(email), password);

      // Проверяем результат через провайдер
      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthorized && authState.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: authState.user!)),
        );
      } else if (authState.error != null) {
        _showError(authState.error!);
      }
    } catch (e) {
      _showError('Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

  // Улучшенный валидатор для поля с учетом touched состояния
  String? _validateField(
    String? value,
    String? Function(String?) validator,
    bool touched,
  ) {
    // Если форма была отправлена, показываем все ошибки
    if (_formSubmitted) {
      return validator(value);
    }
    // Иначе показываем ошибки только для touched полей
    return touched ? validator(value) : null;
  }

  // Валидатор для пароля
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Вход',
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
            child: Form(
              key: _formKey,
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
                          // Fallback если изображение не загрузилось
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
                  Text(
                    'Добро пожаловать',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Войдите в свой аккаунт',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Поле email С ИКОНКОЙ
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@email.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      errorMaxLines: 2,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => _validateField(
                      value,
                      EmailValidator.validate,
                      _emailTouched || _formSubmitted,
                    ),
                    textInputAction: TextInputAction.next,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    onChanged: (value) {
                      if (!_emailTouched) {
                        setState(() => _emailTouched = true);
                      }
                    },
                    onTap: () {
                      if (!_emailTouched) {
                        setState(() => _emailTouched = true);
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Поле пароля С ИКОНКОЙ
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      hintText: 'Введите ваш пароль',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      errorMaxLines: 2,
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => _validateField(
                      value,
                      _validatePassword,
                      _passwordTouched || _formSubmitted,
                    ),
                    textInputAction: TextInputAction.done,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    onChanged: (value) {
                      if (!_passwordTouched) {
                        setState(() => _passwordTouched = true);
                      }
                    },
                    onTap: () {
                      if (!_passwordTouched) {
                        setState(() => _passwordTouched = true);
                      }
                    },
                    onFieldSubmitted: (_) => _login(),
                  ),
                  SizedBox(height: 8),

                  // Ссылка "Забыли пароль?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(),
                              ),
                            ),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Забыли пароль?',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Кнопка входа
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
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
                  SizedBox(height: 24),

                  // Разделитель
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: colorScheme.outline.withOpacity(0.4),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'или',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: colorScheme.outline.withOpacity(0.4),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Ссылка на регистрацию
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Нет аккаунта? ',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterScreen(),
                                ),
                              ),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Зарегистрируйтесь',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
