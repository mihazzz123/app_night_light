// widgets/countdown_snack_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';

class CountdownSnackBar extends StatefulWidget {
  final VoidCallback onNavigate;
  final VoidCallback onTimerComplete;
  final int initialSeconds;

  const CountdownSnackBar({
    Key? key,
    required this.onNavigate,
    required this.onTimerComplete,
    this.initialSeconds = 5,
  }) : super(key: key);

  @override
  State<CountdownSnackBar> createState() => _CountdownSnackBarState();
}

class _CountdownSnackBarState extends State<CountdownSnackBar> {
  int _secondsRemaining = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsRemaining--;
        });

        if (_secondsRemaining <= 0) {
          timer.cancel();
          widget.onTimerComplete();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Регистрация прошла успешно!',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Подтвердите регистрацию через письмо на почте.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 90),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Автоматический переход через $_secondsRemaining секунд...',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 80),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
