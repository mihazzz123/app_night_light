// presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import '../../core/di/app_providers.dart'; // Импортируем провайдеры

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _showError('Пожалуйста, заполните все поля');
      return;
    }

    if (password != confirmPassword) {
      _showError('Пароли не совпадают');
      return;
    }

    if (password.length < 6) {
      _showError('Пароль должен содержать минимум 6 символов');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authViewModel = ref.read(authViewModelProvider.notifier);
      await authViewModel.register(
        email: email,
        password: password,
        name: name,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Имя'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Подтвердите пароль'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: Text('Зарегистрироваться'),
                  ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AuthScreen()),
              ),
              child: Text('Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
