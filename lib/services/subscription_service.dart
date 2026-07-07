import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_template.dart';
import 'api_client.dart';

class SubscriptionService with ChangeNotifier {
  List<SubscriptionTemplate> _templates = [];
  List<SubscriptionPlan> _userPlans = [];
  bool _isLoading = false;

  List<SubscriptionTemplate> get templates => [..._templates];
  List<SubscriptionPlan> get userPlans => [..._userPlans];
  bool get isLoading => _isLoading;

  Future<void> fetchTemplates() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/subscription-templates') as List;
      _templates = data.map((json) => SubscriptionTemplate.fromJson(json)).toList();
    } catch (e) {
      _templates = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserPlans(String userId) async {
    try {
      final data = await ApiClient.get('/subscriptions/user/$userId') as List;
      _userPlans = data.map((json) => SubscriptionPlan.fromJson(json)).toList();
    } catch (e) {
      _userPlans = [];
    }
    notifyListeners();
  }

  Future<SubscriptionPlan> createSubscription({
    required String templateId,
    required List<CartItem> items,
    required List<String> days,
    required String time,
    required String deliveryAddress,
  }) async {
    final body = {
      'templateId': templateId,
      'items': items.map((i) => {'productId': i.product.id, 'quantity': i.quantity}).toList(),
      'days': days,
      'time': time,
      'deliveryAddress': deliveryAddress,
    };

    final data = await ApiClient.post('/subscriptions', body: body);
    final plan = SubscriptionPlan.fromJson(data);
    _userPlans.insert(0, plan);
    notifyListeners();
    return plan;
  }

  Future<SubscriptionPlan> updateSubscription({
    required String subscriptionId,
    required List<CartItem> items,
    required List<String> days,
    required String time,
    required String deliveryAddress,
    required bool active,
  }) async {
    final body = {
      'items': items.map((i) => {'productId': i.product.id, 'quantity': i.quantity}).toList(),
      'days': days,
      'time': time,
      'deliveryAddress': deliveryAddress,
      'active': active,
    };

    final data = await ApiClient.put('/subscriptions/$subscriptionId', body: body);
    final updated = SubscriptionPlan.fromJson(data);
    final index = _userPlans.indexWhere((p) => p.id == subscriptionId);
    if (index >= 0) _userPlans[index] = updated;
    notifyListeners();
    return updated;
  }
}
