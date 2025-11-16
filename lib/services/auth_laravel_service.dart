import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'laravel_api_service.dart';

class AuthLaravelService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _token;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

  // Login with Laravel API
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Call Laravel API
      final response = await LaravelApiService.login(email, password);
      
      // Extract user data from response
      final userData = response['user'];
      _token = response['token'];
      
      // Create User object
      _currentUser = User(
        id: userData['id'].toString(),
        name: userData['name'],
        email: userData['email'],
        phone: '', // Will be updated later
        address: '', // Will be updated later
        loyaltyPoints: 0, // Will be updated later
      );
      
      // Store user data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData));
      await prefs.setString('token', _token!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register with Laravel API
  Future<bool> register(String name, String email, String password, String phone, String address) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Call Laravel API
      final response = await LaravelApiService.register(name, email, password);
      
      // Extract user data from response
      final userData = response['user'];
      _token = response['token'];
      
      // Create User object with additional data
      _currentUser = User(
        id: userData['id'].toString(),
        name: userData['name'],
        email: userData['email'],
        phone: phone,
        address: address,
        loyaltyPoints: 0,
      );
      
      // Store user data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode({
        ...userData,
        'phone': phone,
        'address': address,
        'loyaltyPoints': 0,
      }));
      await prefs.setString('token', _token!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Auto login with stored token
  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      final savedToken = prefs.getString('token');
      
      if (userData != null && savedToken != null) {
        final userMap = jsonDecode(userData);
        _currentUser = User.fromJson(userMap);
        _token = savedToken;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Auto login error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await LaravelApiService.logout();
    } catch (e) {
      print('Logout API error: $e');
    }
    
    _currentUser = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('token');
    
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile(String name, String phone, String address) async {
    try {
      if (_currentUser == null) return false;
      
      _isLoading = true;
      notifyListeners();
      
      // For now, just update locally
      // In a real app, you would call an API endpoint to update the profile
      final userData = {
        'id': _currentUser!.id,
        'name': name,
        'email': _currentUser!.email,
        'phone': phone,
        'address': address,
        'loyaltyPoints': _currentUser!.loyaltyPoints,
      };
      
      _currentUser = User.fromJson(userData);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Profile update error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}