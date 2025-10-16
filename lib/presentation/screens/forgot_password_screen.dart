// presentation/screens/forgot_password_screen.dart
import 'package:app_night_light/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/email_validator.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailTouched = false;
  bool _formSubmitted = false;
  bool _emailSent = false;

  Future<void> _sendResetInstructions() async {
    // Помечаем форму как отправленную для подсветки ошибок
    setState(() {
      _formSubmitted = true;
      _emailTouched = true;
    });

    // Детальная валидация формы
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Имитация отправки email (в реальном приложении здесь будет API вызов)
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _emailSent = true;
        _isLoading = false;
      });

      _showSuccess(
        'Инструкции по восстановлению отправлены на ${emailController.text}',
      );
    } catch (e) {
      _showError('Ошибка: $e');
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

  // Улучшенный валидатор для поля с учетом touched состояния
  String? _validateField(
    String? value,
    String? Function(String?) validator,
    bool touched,
  ) {
    if (_formSubmitted) {
      return validator(value);
    }
    return touched ? validator(value) : null;
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Восстановление пароля',
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
                    'Восстановление пароля',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Подзаголовок
                  if (!_emailSent) ...[
                    Text(
                      'Введите email для сброса пароля',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Text(
                      'Проверьте вашу почту',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 32),

                  if (!_emailSent) ...[
                    // Поле email
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
                      textInputAction: TextInputAction.done,
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
                      onFieldSubmitted: (_) => _sendResetInstructions(),
                    ),
                    SizedBox(height: 16),

                    // Информационный текст
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceVariant,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: 12),
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
                    SizedBox(height: 24),

                    // Кнопка отправки инструкций
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendResetInstructions,
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
                                'Сбросить пароль',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ] else ...[
                    // Сообщение об успешной отправке
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Письмо отправлено!',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'На вашу почту отправлено письмо. Пожалуйста, проверьте папку "Входящие" и "Спам".',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Кнопка возврата к входу
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Войти',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Дополнительная кнопка повторной отправки
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _emailSent = false;
                          _formSubmitted = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                      child: Text(
                        'Отправить еще раз',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Ссылка на вход
                  if (!_emailSent) ...[
                    TextButton(
                      onPressed: _isLoading ? null : _navigateToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                      child: Text(
                        'Войти',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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
    super.dispose();
  }
}
