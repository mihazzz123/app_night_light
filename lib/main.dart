import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';
=======
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/splash_router.dart';
>>>>>>> 3369d78356daa6eaa90e903a21adc27f8349a73b

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Авторизация',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
=======
      title: 'M3Zold Auth App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashRouter(),
>>>>>>> 3369d78356daa6eaa90e903a21adc27f8349a73b
    );
  }
}
