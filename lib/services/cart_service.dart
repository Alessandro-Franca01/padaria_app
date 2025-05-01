import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/product.dart';
import '../models/cart_item.dart';
import 'product_service.dart';

class CartService with ChangeNotifier {
  List<CartItem> _items = [];
  
  List<CartItem> get items => [..._items];
  
  int get itemCount => _items.length;
  
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  
  Future<void> loadCartFromStorage(ProductService productService) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart_data');
    
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      _items = [];
      
      for (var item in decodedData) {
        final product = productService.getProductById(item['productId']);
        if (product != null) {
          _items.add(
            CartItem(
              product: product,
              quantity: item['quantity'],
              notes: item['notes'],
            )
          );
        }
      }
      
      notifyListeners();
    }
  }
  
  Future<void> _saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('cart_data', cartData);
  }
  
  void addItem(Product product, {int quantity = 1, String? notes}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Produto já existe no carrinho, apenas aumenta a quantidade
      _items[existingIndex].quantity += quantity;
    } else {
      // Adiciona um novo item ao carrinho
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          notes: notes,
        )
      );
    }
    
    _saveCartToStorage();
    notifyListeners();
  }
  
  void updateItemQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      _saveCartToStorage();
      notifyListeners();
    }
  }
  
  void updateItemNotes(String productId, String? notes) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].notes = notes;
      _saveCartToStorage();
      notifyListeners();
    }
  }
  
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCartToStorage();
    notifyListeners();
  }
  
  void clear() {
    _items = [];
    _saveCartToStorage();
    notifyListeners();
  }
}
