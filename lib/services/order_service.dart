import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class OrderService with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  
  List<Order> get orders => [..._orders];
  bool get isLoading => _isLoading;
  
  OrderService() {
    _loadOrders();
  }
  
  Future<void> _loadOrders() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = prefs.getString('orders_data');
      
      if (ordersData != null) {
        final List<dynamic> decodedData = jsonDecode(ordersData);
        _orders = [];
        
        for (var orderData in decodedData) {
          // Reconstituir os itens do carrinho
          List<CartItem> orderItems = [];
          for (var itemData in orderData['items']) {
            // Simular produto (em uma app real, isso viria de um banco de dados)
            final product = Product(
              id: itemData['productId'],
              name: itemData['productName'] ?? 'Produto',
              description: itemData['productDescription'] ?? '',
              price: itemData['productPrice']?.toDouble() ?? 0.0,
              imageUrl: _normalizeImagePath(itemData['productImage']),
              category: itemData['productCategory'] ?? 'Geral',
            );
            
            orderItems.add(CartItem(
              product: product,
              quantity: itemData['quantity'],
              notes: itemData['notes'],
            ));
          }
          
          _orders.add(Order.fromJson(orderData, orderItems));
        }
        
        // Ordenar por data mais recente
        _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      } else {
        // Adicionar alguns pedidos de exemplo
        _createSampleOrders();
      }
    } catch (e) {
      print('Erro ao carregar pedidos: $e');
      _createSampleOrders();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Converter pedidos para JSON incluindo dados dos produtos
      List<Map<String, dynamic>> ordersJson = _orders.map((order) {
        Map<String, dynamic> orderData = order.toJson();
        
        // Incluir dados completos dos produtos nos itens
        List<Map<String, dynamic>> itemsWithProductData = order.items.map((item) {
          Map<String, dynamic> itemData = item.toJson();
          itemData['productName'] = item.product.name;
          itemData['productDescription'] = item.product.description;
          itemData['productPrice'] = item.product.price;
          itemData['productImage'] = item.product.imageUrl;
          itemData['productCategory'] = item.product.category;
          return itemData;
        }).toList();
        
        orderData['items'] = itemsWithProductData;
        return orderData;
      }).toList();
      
      await prefs.setString('orders_data', jsonEncode(ordersJson));
    } catch (e) {
      print('Erro ao salvar pedidos: $e');
    }
  }
  
  void _createSampleOrders() {
    // Criar alguns pedidos de exemplo
    final now = DateTime.now();
    
    // Produtos de exemplo
    final breadProduct = Product(
      id: '1',
      name: 'Pão Francês',
      description: 'Pão francês tradicional, fresco e crocante.',
      price: 1.50,
      imageUrl: _normalizeImagePath('assets/images/paes_artesanais.jpeg'),
      category: 'Pães',
    );
    
    final cheeseProduct = Product(
      id: '2',
      name: 'Pão de Queijo',
      description: 'Pão de queijo mineiro, quentinho e macio.',
      price: 2.50,
      imageUrl: _normalizeImagePath('assets/images/salgados_premium.jpeg'),
      category: 'Pães',
    );
    
    final cakeProduct = Product(
      id: '4',
      name: 'Bolo de Chocolate',
      description: 'Bolo de chocolate com cobertura de brigadeiro.',
      price: 30.00,
      imageUrl: _normalizeImagePath('assets/images/bolos_caseiros.jpeg'),
      category: 'Bolos',
    );
    
    _orders = [
      Order(
        id: '${now.millisecondsSinceEpoch}1',
        userId: '1',
        items: [
          CartItem(product: breadProduct, quantity: 10),
          CartItem(product: cheeseProduct, quantity: 6),
        ],
        total: 30.00,
        orderDate: now.subtract(Duration(hours: 2)),
        deliveryDate: now.add(Duration(hours: 4)),
        deliveryAddress: 'Rua da Padaria, 123 - Centro',
        status: OrderStatus.preparing,
        paymentMethod: 'PIX',
      ),
      Order(
        id: '${now.millisecondsSinceEpoch}2',
        userId: '1',
        items: [
          CartItem(product: cakeProduct, quantity: 1),
        ],
        total: 30.00,
        orderDate: now.subtract(Duration(days: 1)),
        deliveryDate: now.subtract(Duration(days: 1)).add(Duration(hours: 6)),
        deliveryAddress: 'Rua da Padaria, 123 - Centro',
        status: OrderStatus.completed,
        paymentMethod: 'Cartão de Crédito',
      ),
      Order(
        id: '${now.millisecondsSinceEpoch}3',
        userId: '1',
        items: [
          CartItem(product: breadProduct, quantity: 20, notes: 'Bem assados, por favor'),
          CartItem(product: cheeseProduct, quantity: 12),
        ],
        total: 60.00,
        orderDate: now.subtract(Duration(days: 3)),
        deliveryDate: now.subtract(Duration(days: 3)).add(Duration(hours: 8)),
        deliveryAddress: 'Rua da Padaria, 123 - Centro',
        status: OrderStatus.completed,
        paymentMethod: 'Dinheiro',
        isRecurring: true,
        recurringDays: ['Segunda', 'Quarta', 'Sexta'],
      ),
    ];
    
    _saveOrders();
  }

  String _normalizeImagePath(String? path) {
    final fallback = 'assets/images/paes_artesanais.jpeg';
    if (path == null || path.isEmpty) return fallback;
    switch (path) {
      case 'assets/images/pao_frances.jpg':
        return 'assets/images/paes_artesanais.jpeg';
      case 'assets/images/pao_queijo.jpg':
        return 'assets/images/salgados_premium.jpeg';
      case 'assets/images/bolo_chocolate.jpg':
        return 'assets/images/bolos_caseiros.jpeg';
      case 'assets/images/croissant.jpg':
        return 'assets/images/salgados_premium.jpeg';
      case 'assets/images/cafe.jpg':
        return 'assets/images/categories/categoria_cafes.webp';
      case 'assets/images/suco_laranja.jpg':
        return 'assets/images/categories/categoria_doces.jpeg';
      case 'assets/images/sanduiche.jpg':
        return 'assets/images/salgados_premium.jpeg';
      case 'assets/images/coxinha.jpg':
        return 'assets/images/salgados_premium.jpeg';
      default:
        return path;
    }
  }
  
  Future<void> addOrder(Order order) async {
    _orders.insert(0, order); // Adicionar no início da lista
    await _saveOrders();
    notifyListeners();
  }
  
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      final oldOrder = _orders[index];
      _orders[index] = Order(
        id: oldOrder.id,
        userId: oldOrder.userId,
        items: oldOrder.items,
        total: oldOrder.total,
        orderDate: oldOrder.orderDate,
        deliveryDate: oldOrder.deliveryDate,
        deliveryAddress: oldOrder.deliveryAddress,
        status: newStatus,
        paymentMethod: oldOrder.paymentMethod,
        isRecurring: oldOrder.isRecurring,
        recurringDays: oldOrder.recurringDays,
      );
      
      await _saveOrders();
      notifyListeners();
    }
  }
  
  Future<void> refreshOrders() async {
    await _loadOrders();
  }
  
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
  
  List<Order> getOrdersByUserId(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }
  
  List<Order> getActiveOrders() {
    return _orders.where((order) => [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.delivery,
    ].contains(order.status)).toList();
  }
  
  List<Order> getCompletedOrders() {
    return _orders.where((order) => [
      OrderStatus.completed,
      OrderStatus.cancelled,
    ].contains(order.status)).toList();
  }
  
  List<Order> getRecurringOrders() {
    return _orders.where((order) => order.isRecurring).toList();
  }
  
  double getTotalSpent(String userId) {
    return _orders
        .where((order) => order.userId == userId && order.status == OrderStatus.completed)
        .fold(0.0, (sum, order) => sum + order.total);
  }
  
  int getTotalOrders(String userId) {
    return _orders.where((order) => order.userId == userId).length;
  }
}