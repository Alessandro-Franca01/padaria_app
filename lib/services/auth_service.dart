import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _token;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

  // Simulação de dados - Em uma aplicação real, isso seria substituído por chamadas à API
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simula chamada de API com atraso
      await Future.delayed(Duration(seconds: 1));
      
      // Simulação de resposta de API
      if (email == 'teste@email.com' && password == '123456') {
        final userData = {
          'id': '1',
          'name': 'Usuário Teste',
          'email': email,
          'phone': '(11) 98765-4321',
          'address': 'Rua da Padaria, 123',
          'loyaltyPoints': 50,
        };
        
        _currentUser = User.fromJson(userData);
        _token = 'simulated_token_${DateTime.now().millisecondsSinceEpoch}';
        
        // Salva dados do usuário no armazenamento seguro
        await _storage.write(key: 'user_data', value: jsonEncode(userData));
        await _storage.write(key: 'auth_token', value: _token);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String phone, String address) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simula chamada de API com atraso
      await Future.delayed(Duration(seconds: 1));
      
      // Simulação de resposta de API
      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'loyaltyPoints': 0,
      };
      
      _currentUser = User.fromJson(userData);
      _token = 'simulated_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Salva dados do usuário no armazenamento seguro
      await _storage.write(key: 'user_data', value: jsonEncode(userData));
      await _storage.write(key: 'auth_token', value: _token);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
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
    _currentUser = null;
    _token = null;
    await _storage.delete(key: 'user_data');
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String phone, String address) async {
    try {
      if (_currentUser == null) return false;
      
      _isLoading = true;
      notifyListeners();
      
      // Simula chamada de API com atraso
      await Future.delayed(Duration(seconds: 1));
      
      // Atualiza dados do usuário
      final userData = {
        'id': _currentUser!.id,
        'name': name,
        'email': _currentUser!.email,
        'phone': phone,
        'address': address,
        'loyaltyPoints': _currentUser!.loyaltyPoints,
      };
      
      _currentUser = User.fromJson(userData);
      
      // Salva dados atualizados
      await _storage.write(key: 'user_data', value: jsonEncode(userData));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
