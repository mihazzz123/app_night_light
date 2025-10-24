import 'package:flutter/material.dart';
import '../../domain/entities/main_state.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _getDeviceIcon(device),
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: логика включения/выключения
              },
              child: Text(device.isOnline ? 'Выключить' : 'Включить'),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Tooltip(
                  message: 'Локальная сеть',
                  child: Icon(
                    Icons.home,
                    color: device.isLocalOnline
                        ? Colors.green.withOpacity(0.7)
                        : Colors.red.withOpacity(0.4),
                  ),
                ),
                Tooltip(
                  message: 'Интернет',
                  child: Icon(
                    Icons.public,
                    color: device.isOnline
                        ? Colors.green.withOpacity(0.7)
                        : Colors.red.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(Device device) {
    switch (device.name.toLowerCase()) {
      case 'thermostat':
        return Icons.thermostat;
      case 'light':
        return Icons.light;
      case 'tv':
        return Icons.tv;
      case 'camera':
        return Icons.videocam;
      case 'fan':
        return Icons.toys;
      case 'router':
        return Icons.router;
      default:
        return Icons.device_unknown;
    }
  }
}
