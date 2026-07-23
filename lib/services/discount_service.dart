import 'package:flutter/material.dart';
import '../models/discount.dart';
import 'api_client.dart';

class DiscountService with ChangeNotifier {
  List<Discount> _discounts = [];
  bool _isLoading = false;

  List<Discount> get discounts => [..._discounts];
  bool get isLoading => _isLoading;

  DiscountService() {
    _loadDiscounts();
  }

  Future<void> _loadDiscounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/discounts') as List;
      _discounts = data.map((json) => Discount.fromJson(json)).toList();
    } catch (e) {
      _discounts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshDiscounts() async {
    await _loadDiscounts();
  }
}
