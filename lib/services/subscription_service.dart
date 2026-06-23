import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/subscription_plan.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'product_service.dart';

class SubscriptionService with ChangeNotifier {
  SubscriptionPlan? _plan;
  late final List<SubscriptionPlan> _userPlans = _buildMockUserPlans();

  SubscriptionPlan? get plan => _plan;
  List<CartItem> get items => _plan?.items ?? [];
  List<String> get days => _plan?.days ?? [];
  String get time => _plan?.time ?? '';
  String get address => _plan?.deliveryAddress ?? '';
  bool get active => _plan?.active ?? false;
  List<SubscriptionPlan> get userPlans => List.unmodifiable(_userPlans);

  List<SubscriptionPlan> _buildMockUserPlans() {
    final Product paoFrances = Product(
      id: 'p1',
      name: 'Pão Francês',
      description: 'Pão francês tradicional, fresco e crocante.',
      price: 1.50,
      imageUrl: 'assets/images/paes_artesanais.jpeg',
      category: 'Pães',
    );

    final Product boloChocolate = Product(
      id: 'd1',
      name: 'Bolo de Chocolate',
      description: 'Bolo de chocolate com cobertura de brigadeiro.',
      price: 25.00,
      imageUrl: 'assets/images/bolos_caseiros.jpeg',
      category: 'Bolos',
    );

    final Product cafe = Product(
      id: 'b1',
      name: 'Café Coado',
      description: 'Café coado na hora.',
      price: 5.00,
      imageUrl: 'assets/images/categories/categoria_cafes.webp',
      category: 'Bebidas',
    );

    return [
      SubscriptionPlan(
        id: 'plano-cafe-da-manha',
        userId: 'user-1',
        items: [
          CartItem(product: paoFrances, quantity: 6),
          CartItem(product: cafe, quantity: 2),
        ],
        days: ['Seg', 'Qua', 'Sex'],
        time: '08:00',
        deliveryAddress: 'Rua Exemplo, 123 - Centro',
        active: true,
      ),
      SubscriptionPlan(
        id: 'plano-lanche-da-tarde',
        userId: 'user-1',
        items: [
          CartItem(product: boloChocolate, quantity: 1),
          CartItem(product: paoFrances, quantity: 4),
        ],
        days: ['Ter', 'Qui'],
        time: '15:00',
        deliveryAddress: 'Rua Exemplo, 123 - Centro',
        active: false,
      ),
    ];
  }

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
}
