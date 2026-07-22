import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'api_client.dart';

class OrderService with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => [..._orders];
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/orders/user/$userId') as List;
      _orders = data.map((json) => _orderFromJson(json)).toList();
    } catch (e) {
      _orders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order> createOrder({
    required List<CartItem> items,
    required String deliveryAddress,
    required DateTime deliveryDate,
    String? paymentMethod,
    bool isRecurring = false,
    List<String>? recurringDays,
  }) async {
    final body = {
      'items': items.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
        'notes': item.notes,
      }).toList(),
      'deliveryAddress': deliveryAddress,
      'deliveryDate': deliveryDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isRecurring': isRecurring,
      'recurringDays': isRecurring ? (recurringDays ?? []) : <String>[],
    };

    final data = await ApiClient.post('/orders', body: body);
    final order = _orderFromJson(data);
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  Future<Order> cancelOrder(String orderId) async {
    final data = await ApiClient.post('/orders/$orderId/cancel');
    final updated = _orderFromJson(data);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) _orders[index] = updated;
    notifyListeners();
    return updated;
  }

  Order _orderFromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List).map((itemJson) {
      final thinProduct = Product(
        id: itemJson['productId'],
        name: itemJson['productName'],
        description: '',
        price: (itemJson['unitPrice'] as num).toDouble(),
        imageUrl: itemJson['imageUrl'] ?? '',
        category: '',
      );
      return CartItem(
        product: thinProduct,
        quantity: itemJson['quantity'],
        notes: itemJson['notes'],
      );
    }).toList();

    return Order.fromJson(json, items);
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
}
