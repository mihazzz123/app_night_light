import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../storage/token_storage.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout(); // очистка токена
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главный экран'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<String?>(
          future: TokenStorage.getToken(),
          builder: (context, snapshot) {
            final token = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Вы авторизованы!', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                Text(
                  'Ваш токен:\n${token ?? "не найден"}',
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
