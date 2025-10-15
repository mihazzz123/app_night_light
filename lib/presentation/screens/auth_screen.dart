// presentation/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../../core/di/app_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Пожалуйста, заполните все поля')));
      return;
    }

    final authViewModel = ref.read(authViewModelProvider.notifier);
    await authViewModel.login(email, password);

    // Проверяем состояние после логина
    final authState = ref.read(authViewModelProvider);
    if (authState.isAuthorized && authState.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: authState.user!)),
      );
    } else if (authState.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authState.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Center(
        // Центрируем всю форму
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
          ), // Максимальная ширина формы
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Занимает только необходимое пространство
            children: [
              Image.asset('assets/images/logo.png', height: 100, width: 100),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Кнопка на всю ширину контейнера
                child: ElevatedButton(onPressed: _login, child: Text('Войти')),
              ),
              SizedBox(height: 16),
              Text('или', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity, // Кнопка на всю ширину контейнера
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text('Зарегистрироваться'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
