import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _token;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await ApiClient.post(
        '/login',
        body: {'email': email, 'password': password},
        withAuth: false,
      );

      await _persistSession(data);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, String phone, String address) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await ApiClient.post(
        '/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
          'address': address,
        },
        withAuth: false,
      );

      await _persistSession(data);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      final savedToken = await _storage.read(key: 'auth_token');

      if (userData != null && savedToken != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
        _token = savedToken;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('/logout');
    } catch (e) {
      // logout no backend é best-effort; sessão local é limpa de qualquer forma
    }
    await clearSession();
  }

  /// Limpa a sessão local sem chamar a API — usado quando o token já é
  /// inválido/expirado (resposta 401) e não há motivo para avisar o backend.
  Future<void> clearSession() async {
    _currentUser = null;
    _token = null;
    await _storage.delete(key: 'user_data');
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String phone, String address) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await ApiClient.put(
        '/users/me',
        body: {'name': name, 'phone': phone, 'address': address},
      );

      _currentUser = User.fromJson(data);
      await _storage.write(key: 'user_data', value: jsonEncode(data));
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistSession(dynamic data) async {
    _currentUser = User.fromJson(data['user']);
    _token = data['token'];
    await _storage.write(key: 'user_data', value: jsonEncode(data['user']));
    await _storage.write(key: 'auth_token', value: _token);
  }
}
