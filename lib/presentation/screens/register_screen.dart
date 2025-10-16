// presentation/screens/register_screen.dart
import 'package:app_night_light/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import '../../core/di/app_providers.dart';
import '../../core/utils/email_validator.dart';
import '../../core/utils/password_validator.dart';
import '../../core/error/validation_errors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Переменные для отслеживания touched состояний полей
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;

  // Переменная для отслеживания попытки отправки формы
  bool _formSubmitted = false;

  // Валидация входных данных (аналогично Go методу validateInput)
  bool _validateInput() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty) {
      _showError(ValidationErrors.emailRequired);
      return false;
    }

    if (password.isEmpty) {
      _showError(ValidationErrors.passwordRequired);
      return false;
    }

    if (password != confirmPassword) {
      _showError(ValidationErrors.passwordConfirm);
      return false;
    }

    if (password.length < 8) {
      _showError(ValidationErrors.weakPassword);
      return false;
    }

    return true;
  }

  Future<void> _register() async {
    // Помечаем форму как отправленную для подсветки ошибок
    setState(() {
      _formSubmitted = true;
      _emailTouched = true;
      _passwordTouched = true;
      _confirmPasswordTouched = true;
    });

    // Первая проверка как в Go (базовая валидация)
    if (!_validateInput()) {
      return;
    }

    // Детальная валидация формы
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      await authViewModel.register(
        email: EmailValidator.normalize(emailController.text),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      // Проверяем состояние после регистрации
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

  String? _validateConfirmPassword(String? value) {
    return PasswordValidator.validate(
      value,
      confirmPassword: passwordController.text,
    );
  }

  String? _validatePassword(String? value) {
    return PasswordValidator.validate(value);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Регистрация',
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
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 30),
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

                  // Заголовок
                  Text(
                    'Создайте аккаунт',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Подзаголовок
                  Text(
                    'Заполните данные для регистрации',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 60),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Поле email
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@email.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: colorScheme.onSurface.withValues(alpha: 60),
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

                  // Поле пароля
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      hintText: 'Минимум 8 символов',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurface.withValues(alpha: 60),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 60),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      errorMaxLines: 3,
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => _validateField(
                      value,
                      _validatePassword,
                      _passwordTouched || _formSubmitted,
                    ),
                    textInputAction: TextInputAction.next,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    onChanged: (value) {
                      if (!_passwordTouched) {
                        setState(() => _passwordTouched = true);
                      }
                      // Обновляем валидацию подтверждения пароля при изменении основного пароля
                      if (_confirmPasswordTouched || _formSubmitted) {
                        _formKey.currentState!.validate();
                      }
                    },
                    onTap: () {
                      if (!_passwordTouched) {
                        setState(() => _passwordTouched = true);
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Поле подтверждения пароля
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Подтвердите пароль',
                      hintText: 'Повторите пароль',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurface.withValues(alpha: 60),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 60),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      errorMaxLines: 2,
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => _validateField(
                      value,
                      _validateConfirmPassword,
                      _confirmPasswordTouched || _formSubmitted,
                    ),
                    textInputAction: TextInputAction.done,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    onChanged: (value) {
                      if (!_confirmPasswordTouched) {
                        setState(() => _confirmPasswordTouched = true);
                      }
                    },
                    onTap: () {
                      if (!_confirmPasswordTouched) {
                        setState(() => _confirmPasswordTouched = true);
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Подсказка для пароля
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest,
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        'Требования к паролю',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      initiallyExpanded: false,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPasswordRequirement(
                                'Минимум 8 символов',
                                colorScheme,
                              ),
                              _buildPasswordRequirement(
                                'Заглавные и строчные буквы',
                                colorScheme,
                              ),
                              _buildPasswordRequirement('Цифры', colorScheme),
                              _buildPasswordRequirement(
                                'Специальные символы',
                                colorScheme,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Кнопка регистрации
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
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
                              'Зарегистрироваться',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Ссылка на вход
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          ),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                    child: Text(
                      'Уже есть аккаунт? Войти',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: colorScheme.primary,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
