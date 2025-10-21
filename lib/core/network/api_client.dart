// core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_response.dart';
import '../../core/utils/token_storage.dart';

class ApiClient {
  final String baseUrl;
  final Future<String?> Function() getToken;

  ApiClient({
    required this.baseUrl,
    required this.getToken,
  });

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    return _request<T>(
      'GET',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    return _request<T>(
      'POST',
      endpoint,
      headers: headers,
      body: body,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    return _request<T>(
      'PUT',
      endpoint,
      headers: headers,
      body: body,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    return _request<T>(
      'PATCH',
      endpoint,
      headers: headers,
      body: body,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    return _request<T>(
      'DELETE',
      endpoint,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      // Получаем токен
      final token = await getToken();

      // Формируем заголовки
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      // Формируем URL
      String url = '$baseUrl$endpoint';
      if (queryParameters != null) {
        final uri = Uri.parse(url).replace(queryParameters: queryParameters);
        url = uri.toString();
      }

      // Создаем запрос
      final request = http.Request(method, Uri.parse(url));
      request.headers.addAll(requestHeaders);

      if (body != null) {
        request.body = jsonEncode(body);
      }

      // Отправляем запрос
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Обрабатываем ответ
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      // Проверяем статус код
      if (response.statusCode == 401) {
        // Токен истек или невалиден - очищаем токены
        await TokenStorage.clearTokens();
        return ApiResponse<T>(
          success: false,
          data: null,
          message: 'Token expired',
          statusCode: response.statusCode,
        );
      }

      // Парсим данные если предоставлен fromJsonT
      T? data;
      if (fromJsonT != null && responseBody['data'] != null) {
        try {
          data = fromJsonT(responseBody['data']);
        } catch (e) {
          print('Error parsing response data: $e');
        }
      } else {
        data = responseBody['data'] as T?;
      }

      return ApiResponse<T>(
        success: responseBody['success'] ??
            (response.statusCode >= 200 && response.statusCode < 300),
        data: data,
        message: responseBody['message'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('API Request error: $e');
      return ApiResponse<T>(
        success: false,
        data: null,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  // Метод для загрузки файлов
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    List<int> fileBytes,
    String fileName, {
    Map<String, String>? fields,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final token = await getToken();

      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Добавляем файл
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

      // Добавляем дополнительные поля
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 401) {
        await TokenStorage.clearTokens();
      }

      // Парсим данные
      T? data;
      if (fromJsonT != null && jsonResponse['data'] != null) {
        data = fromJsonT(jsonResponse['data']);
      } else {
        data = jsonResponse['data'] as T?;
      }

      return ApiResponse<T>(
        success: response.statusCode >= 200 && response.statusCode < 300,
        data: data,
        message: jsonResponse['message'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        data: null,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
