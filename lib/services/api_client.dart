import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String error;
  final String message;
  final Map<String, String>? fieldErrors;

  ApiException({
    required this.statusCode,
    required this.error,
    required this.message,
    this.fieldErrors,
  });

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> storeToken(String token) => _storage.write(key: _tokenKey, value: token);

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String path, {bool withAuth = true}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body, bool withAuth = true}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, {Map<String, dynamic>? body, bool withAuth = true}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    Map<String, dynamic> body = {};
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      // corpo de erro não era JSON; segue com valores padrão
    }

    throw ApiException(
      statusCode: response.statusCode,
      error: body['error']?.toString() ?? 'Error',
      message: body['message']?.toString() ?? 'Erro inesperado (${response.statusCode}).',
      fieldErrors: body['fieldErrors'] != null
          ? Map<String, String>.from(body['fieldErrors'])
          : null,
    );
  }
}
