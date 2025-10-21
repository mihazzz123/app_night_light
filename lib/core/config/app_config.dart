// core/config/app_config.dart
class AppConfig {
  final String baseUrl;
  final String apiVersion;
  final int timeoutSeconds;

  const AppConfig({
    required this.baseUrl,
    this.apiVersion = 'v1',
    this.timeoutSeconds = 30,
  });

  String get apiBaseUrl => baseUrl;
}

// Development config
const devConfig = AppConfig(
  baseUrl: 'https://api.m3zold-lab.tech/',
  apiVersion: 'v1',
);

// Production config
const prodConfig = AppConfig(
  baseUrl: 'https://api.m3zold-lab.tech/',
  apiVersion: 'v1',
);
