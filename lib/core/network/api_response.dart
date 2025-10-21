// core/network/api_response.dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.data,
    this.message,
    required this.statusCode,
  });

  // Вспомогательные методы
  bool get hasData => data != null;
  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, message: $message, statusCode: $statusCode)';
  }
}
