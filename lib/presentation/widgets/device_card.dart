import 'package:flutter/material.dart';

import '../../domain/entities/main_state.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onToggle;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOnline = device.isOnline;
    final isLocalOnline = device.isLocalOnline;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getDeviceIcon(device),
                      size: 40,
                      color: isOnline
                          ? colorScheme.primary
                          : colorScheme.onPrimary.withAlpha(60),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      device.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // ✅ Иконки состояния в правом верхнем углу
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  if (isLocalOnline)
                    Tooltip(
                      message: 'Подключено в локальной сети',
                      child: Icon(
                        Icons.home,
                        size: 16,
                        color: colorScheme.tertiary.withAlpha(95),
                      ),
                    ),
                  const SizedBox(
                    width: 4,
                  ),
                  if (isOnline)
                    Tooltip(
                      message: 'Подключено к интернету',
                      child: Icon(
                        Icons.public,
                        size: 16,
                        color: colorScheme.tertiary.withAlpha(95),
                      ),
                    ),
                ],
              ),
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
