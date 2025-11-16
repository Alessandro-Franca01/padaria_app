import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Store token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storeToken(data['token']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await storeToken(data['token']);
      return data;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Get categories
  static Future<List<dynamic>> getCategories() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load categories: ${response.body}');
    }
  }

  // Get products
  static Future<List<dynamic>> getProducts() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  // Get products by category
  static Future<List<dynamic>> getProductsByCategory(int categoryId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$categoryId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products by category: ${response.body}');
    }
  }

  // Get user orders
  static Future<List<dynamic>> getUserOrders(int userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user orders: ${response.body}');
    }
  }

  // Create order
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  // Get user subscription plans
  static Future<List<dynamic>> getUserSubscriptionPlans(int userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/subscription-plans/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user subscription plans: ${response.body}');
    }
  }

  // Create subscription plan
  static Future<Map<String, dynamic>> createSubscriptionPlan(Map<String, dynamic> planData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/subscription-plans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(planData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create subscription plan: ${response.body}');
    }
  }

  // Get user chat messages
  static Future<List<dynamic>> getUserChatMessages(int userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/chat-messages/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user chat messages: ${response.body}');
    }
  }

  // Send chat message
  static Future<Map<String, dynamic>> sendChatMessage(Map<String, dynamic> messageData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/chat-messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(messageData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send chat message: ${response.body}');
    }
  }

  // Logout
  static Future<void> logout() async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await removeToken();
    } else {
      throw Exception('Failed to logout: ${response.body}');
    }
  }
}