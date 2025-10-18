// presentation/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/app_providers.dart';
import '../../core/utils/email_validator.dart';
import '../../core/utils/password_validator.dart';
import 'home_screen.dart';
import '../../domain/entities/user_entity.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Контроллеры для логина
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Контроллеры для регистрации
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();

  // Контроллеры для восстановления пароля
  final forgotPasswordEmailController = TextEditingController();

  // Ключи форм
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _forgotPasswordFormKey = GlobalKey<FormState>();

  // Состояния
  bool _isLoading = false;
  bool _loginObscurePassword = true;
  bool _registerObscurePassword = true;
  bool _registerObscureConfirmPassword = true;

  // Состояния для диалога восстановления пароля
  bool _showForgotPasswordDialogState = false;
  bool _isSendingResetInstructionsState = false;
  bool _resetInstructionsSentState = false;

  // Состояния touched для улучшенной валидации
  bool _loginEmailTouched = false;
  bool _loginPasswordTouched = false;
  bool _registerEmailTouched = false;
  bool _registerPasswordTouched = false;
  bool _registerConfirmPasswordTouched = false;
  bool _forgotPasswordEmailTouched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Слушатель для сброса состояний при переключении вкладок
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // Сбрасываем состояния touched при переключении вкладок
    if (!_tabController.indexIsChanging) {
      setState(() {
        _loginEmailTouched = false;
        _loginPasswordTouched = false;
        _registerEmailTouched = false;
        _registerPasswordTouched = false;
        _registerConfirmPasswordTouched = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    forgotPasswordEmailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loginEmailTouched = true;
      _loginPasswordTouched = true;
    });

    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      await authViewModel.login(
        EmailValidator.normalize(loginEmailController.text.trim()),
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

  Future<void> _register() async {
    setState(() {
      _registerEmailTouched = true;
      _registerPasswordTouched = true;
      _registerConfirmPasswordTouched = true;
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
        EmailValidator.normalize(email),
        password,
        confirmPassword,
      );

      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthorized && authState.user != null) {
        _navigateToHome(authState.user!);
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

  Future<void> _sendResetInstructions() async {
    setState(() => _forgotPasswordEmailTouched = true);

    if (!_forgotPasswordFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSendingResetInstructionsState = true);

    try {
      // Имитация отправки email (в реальном приложении здесь будет API вызов)
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _resetInstructionsSentState = true;
        _isSendingResetInstructionsState = false;
      });

      _showSuccess(
        'Инструкции по восстановлению отправлены на ${forgotPasswordEmailController.text}',
      );
    } catch (e) {
      _showError('Ошибка при отправке: $e');
      setState(() => _isSendingResetInstructionsState = false);
    }
  }

  void _showForgotPasswordDialog() {
    setState(() {
      _showForgotPasswordDialogState = true;
      _resetInstructionsSentState = false;
      _forgotPasswordEmailTouched = false;
      forgotPasswordEmailController.clear();
    });
  }

  void _closeForgotPasswordDialog() {
    setState(() {
      _showForgotPasswordDialogState = false;
    });
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Улучшенный валидатор с учетом touched состояния
  String? _validateField(
    String? value,
    String? Function(String?) validator,
    bool touched,
  ) {
    return touched ? validator(value) : null;
  }

  // Диалог восстановления пароля
  Widget _buildForgotPasswordDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _forgotPasswordFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Text(
                'Восстановление пароля',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              if (!_resetInstructionsSentState) ...[
                // Описание
                Text(
                  'Введите email для сброса пароля',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Поле email
                TextFormField(
                  controller: forgotPasswordEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => _validateField(
                    value,
                    EmailValidator.validate,
                    _forgotPasswordEmailTouched,
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    if (!_forgotPasswordEmailTouched) {
                      setState(() => _forgotPasswordEmailTouched = true);
                    }
                  },
                  onFieldSubmitted: (_) => _sendResetInstructions(),
                ),
                const SizedBox(height: 24),

                // Информационный текст
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'На вашу почту придет ссылка для сброса пароля',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _closeForgotPasswordDialog,
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSendingResetInstructionsState
                            ? null
                            : _sendResetInstructions,
                        child: _isSendingResetInstructionsState
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Отправить'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Сообщение об успешной отправке
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Письмо отправлено!',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'На вашу почту отправлено письмо. Пожалуйста, проверьте папку "Входящие" и "Спам".',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Кнопка закрытия
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _closeForgotPasswordDialog,
                    child: const Text('Понятно'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Night Light',
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Вход'),
            Tab(text: 'Регистрация'),
          ],
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // ВКЛАДКА ВХОДА
              _buildLoginTab(colorScheme, textTheme),
              // ВКЛАДКА РЕГИСТРАЦИИ
              _buildRegisterTab(colorScheme, textTheme),
            ],
          ),

          // Диалог восстановления пароля
          if (_showForgotPasswordDialogState)
            ModalBarrier(
              color: Colors.black54,
              dismissible: true,
              onDismiss: _closeForgotPasswordDialog,
            ),
          if (_showForgotPasswordDialogState) _buildForgotPasswordDialog(),
        ],
      ),
    );
  }

  Widget _buildLoginTab(ColorScheme colorScheme, TextTheme textTheme) {
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
                color: colorScheme.onSurface.withOpacity(0.6),
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
                EmailValidator.validate,
                _loginEmailTouched,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (!_loginEmailTouched) {
                  setState(() => _loginEmailTouched = true);
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
                  icon: Icon(_loginObscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () {
                    setState(() {
                      _loginObscurePassword = !_loginObscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _loginObscurePassword,
              validator: (value) => _validateField(
                value,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
                _loginPasswordTouched,
              ),
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                if (!_loginPasswordTouched) {
                  setState(() => _loginPasswordTouched = true);
                }
              },
              onFieldSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 8),

            // Забыли пароль
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _showForgotPasswordDialog,
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

  Widget _buildRegisterTab(ColorScheme colorScheme, TextTheme textTheme) {
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
                EmailValidator.validate,
                _registerEmailTouched,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (!_registerEmailTouched) {
                  setState(() => _registerEmailTouched = true);
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
                  icon: Icon(_registerObscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () {
                    setState(() {
                      _registerObscurePassword = !_registerObscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _registerObscurePassword,
              validator: (value) => _validateField(
                value,
                PasswordValidator.validate,
                _registerPasswordTouched,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (!_registerPasswordTouched) {
                  setState(() => _registerPasswordTouched = true);
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
                  icon: Icon(_registerObscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () {
                    setState(() {
                      _registerObscureConfirmPassword =
                          !_registerObscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _registerObscureConfirmPassword,
              validator: (value) => _validateField(
                value,
                (value) => PasswordValidator.validate(
                  value,
                  confirmPassword: registerPasswordController.text,
                ),
                _registerConfirmPasswordTouched,
              ),
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                if (!_registerConfirmPasswordTouched) {
                  setState(() => _registerConfirmPasswordTouched = true);
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
}
