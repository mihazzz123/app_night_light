import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

class HomeScreen extends StatelessWidget {
  final UserEntity user;

  const HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Главная')),
      body: Center(child: Text('Привет, ${user.email}')),
    );
  }
}
