import 'package:flutter/material.dart';
import '../models/category.dart';
import 'api_client.dart';

class CategoryService with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => [..._categories];
  bool get isLoading => _isLoading;

  CategoryService() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/categories') as List;
      _categories = data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      _categories = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshCategories() async {
    await _loadCategories();
  }
}
