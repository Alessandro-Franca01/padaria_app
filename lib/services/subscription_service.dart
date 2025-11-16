import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/subscription_plan.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'product_service.dart';
import 'laravel_api_service.dart';

class SubscriptionService with ChangeNotifier {
  SubscriptionPlan? _plan;
  bool _isSubmitting = false;

  SubscriptionPlan? get plan => _plan;
  List<CartItem> get items => _plan?.items ?? [];
  List<String> get days => _plan?.days ?? [];
  String get time => _plan?.time ?? '';
  String get address => _plan?.deliveryAddress ?? '';
  bool get active => _plan?.active ?? false;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadFromStorage(ProductService productService) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('subscription_plan');
    if (data != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(data);
      final List<CartItem> planItems = [];
      final List<dynamic> itemsJson = jsonMap['items'] ?? [];
      for (var item in itemsJson) {
        final Product? product = productService.getProductById(item['productId']);
        if (product != null) {
          planItems.add(CartItem.fromJson(item, product));
        }
      }
      _plan = SubscriptionPlan(
        id: jsonMap['id'] ?? 'plan-1',
        userId: jsonMap['userId'] ?? 'user-1',
        items: planItems,
        days: List<String>.from(jsonMap['days'] ?? []),
        time: jsonMap['time'] ?? '',
        deliveryAddress: jsonMap['deliveryAddress'] ?? '',
        active: jsonMap['active'] ?? true,
      );
      notifyListeners();
    }
  }

  Future<void> loadFromApi(String userId, ProductService productService) async {
    try {
      final plans = await LaravelApiService.getUserSubscriptionPlans(int.tryParse(userId) ?? 0);
      if (plans.isNotEmpty) {
        final planJson = plans.first;
        final List<CartItem> planItems = [];
        final itemsJson = planJson['subscription_items'] ?? [];
        for (var item in itemsJson) {
          final productJson = item['product'] ?? {};
          final product = Product.fromJson(productJson);
          planItems.add(CartItem.fromJson({'productId': product.id, 'quantity': item['quantity']}, product));
        }
        final apiDays = List<String>.from(planJson['days'] ?? []);
        final uiDays = _mapApiDaysToUi(apiDays);
        _plan = SubscriptionPlan(
          id: planJson['id'].toString(),
          userId: (planJson['user_id'] ?? '').toString(),
          items: planItems,
          days: uiDays,
          time: planJson['delivery_time'] ?? '',
          deliveryAddress: planJson['delivery_address'] ?? '',
          active: (planJson['status'] ?? 'active') == 'active',
        );
        notifyListeners();
      }
    } catch (e) {
      // fallback silently
    }
  }

  Future<void> _save() async {
    if (_plan == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_plan!.toJson());
    await prefs.setString('subscription_plan', data);
  }

  void initialize(String userId) {
    _plan = SubscriptionPlan(
      id: 'plan-1',
      userId: userId,
      items: [],
      days: [],
      time: '',
      deliveryAddress: '',
      active: true,
    );
    _save();
    notifyListeners();
  }

  void toggleProduct(Product product) {
    if (_plan == null) return;
    final index = _plan!.items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _plan!.items.removeAt(index);
    } else {
      _plan!.items.add(CartItem(product: product, quantity: 1));
    }
    _save();
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    if (_plan == null) return;
    if (quantity <= 0) {
      _plan!.items.removeWhere((i) => i.product.id == product.id);
    } else {
      final index = _plan!.items.indexWhere((i) => i.product.id == product.id);
      if (index >= 0) {
        _plan!.items[index].quantity = quantity;
      } else {
        _plan!.items.add(CartItem(product: product, quantity: quantity));
      }
    }
    _save();
    notifyListeners();
  }

  void setDays(List<String> newDays) {
    if (_plan == null) return;
    _plan!.days = newDays;
    _save();
    notifyListeners();
  }

  void setTime(String newTime) {
    if (_plan == null) return;
    _plan!.time = newTime;
    _save();
    notifyListeners();
  }

  void setAddress(String newAddress) {
    if (_plan == null) return;
    _plan!.deliveryAddress = newAddress;
    _save();
    notifyListeners();
  }

  void setActive(bool value) {
    if (_plan == null) return;
    _plan!.active = value;
    _save();
    notifyListeners();
  }

  Future<bool> submitToApi() async {
    if (_plan == null) return false;
    _isSubmitting = true;
    notifyListeners();
    try {
      final daysApi = _mapUiDaysToApi(_plan!.days);
      final itemsPayload = _plan!.items.map((i) => {
            'product_id': int.tryParse(i.product.id) ?? 0,
            'quantity': i.quantity,
          }).toList();
      final payload = {
        'user_id': int.tryParse(_plan!.userId) ?? 0,
        'name': 'Plano App',
        'total_price': _plan!.items.fold<double>(0.0, (sum, i) => sum + i.totalPrice),
        'days': daysApi,
        'delivery_time': _plan!.time,
        'delivery_address': _plan!.deliveryAddress,
        'items': itemsPayload,
      };
      await LaravelApiService.createSubscriptionPlan(payload);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  List<String> _mapUiDaysToApi(List<String> uiDays) {
    final map = {
      'Seg': 'monday',
      'Ter': 'tuesday',
      'Qua': 'wednesday',
      'Qui': 'thursday',
      'Sex': 'friday',
      'Sáb': 'saturday',
      'Dom': 'sunday',
    };
    return uiDays.map((d) => map[d] ?? d).toList();
  }

  List<String> _mapApiDaysToUi(List<String> apiDays) {
    final map = {
      'monday': 'Seg',
      'tuesday': 'Ter',
      'wednesday': 'Qua',
      'thursday': 'Qui',
      'friday': 'Sex',
      'saturday': 'Sáb',
      'sunday': 'Dom',
    };
    return apiDays.map((d) => map[d] ?? d).toList();
  }
}
