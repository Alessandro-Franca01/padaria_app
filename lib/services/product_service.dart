import 'package:flutter/material.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  
  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  
  List<Product> get featuredProducts => 
      _products.where((product) => product.isFeatured).toList();
      
  List<String> get categories {
    final Set<String> categoriesSet = {};
    for (var product in _products) {
      categoriesSet.add(product.category);
    }
    return categoriesSet.toList()..sort();
  }
  
  // Inicializa com dados de exemplo
  ProductService() {
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/products') as List;
      _products = data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> refreshProducts() async {
    await _loadProducts();
  }
  
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
  
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return [];
    
    final queryLower = query.toLowerCase();
    return _products.where((product) => 
      product.name.toLowerCase().contains(queryLower) || 
      product.description.toLowerCase().contains(queryLower)
    ).toList();
  }
}
