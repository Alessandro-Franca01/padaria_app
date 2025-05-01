import 'package:intl/intl.dart';
import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  delivery,
  completed,
  cancelled
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final OrderStatus status;
  final String? paymentMethod;
  final bool isRecurring;
  final List<String>? recurringDays;
  
  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    this.status = OrderStatus.pending,
    this.paymentMethod,
    this.isRecurring = false,
    this.recurringDays,
  });
  
  String get formattedOrderDate => DateFormat('dd/MM/yyyy HH:mm').format(orderDate);
  String get formattedDeliveryDate => deliveryDate != null 
      ? DateFormat('dd/MM/yyyy HH:mm').format(deliveryDate!) 
      : 'Não definido';
  
  String get statusText {
    switch (status) {
      case OrderStatus.pending: return 'Pendente';
      case OrderStatus.confirmed: return 'Confirmado';
      case OrderStatus.preparing: return 'Em preparação';
      case OrderStatus.delivery: return 'Em entrega';
      case OrderStatus.completed: return 'Concluído';
      case OrderStatus.cancelled: return 'Cancelado';
      default: return 'Desconhecido';
    }
  }
  
  factory Order.fromJson(Map<String, dynamic> json, List<CartItem> orderItems) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      items: orderItems,
      total: json['total'].toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      deliveryAddress: json['deliveryAddress'],
      status: OrderStatus.values[json['status'] ?? 0],
      paymentMethod: json['paymentMethod'],
      isRecurring: json['isRecurring'] ?? false,
      recurringDays: json['recurringDays'] != null 
          ? List<String>.from(json['recurringDays']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'status': status.index,
      'paymentMethod': paymentMethod,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
    };
  }
}
