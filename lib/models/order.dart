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
    final idVal = json['id']?.toString();
    final userIdVal = json['userId']?.toString() ?? json['user_id']?.toString() ?? '';
    final totalVal = (json['total'] ?? json['total_amount']) is String
        ? double.tryParse((json['total'] ?? json['total_amount'])) ?? 0.0
        : ((json['total'] ?? json['total_amount'])?.toDouble() ?? 0.0);
    final orderDateStr = json['orderDate'] ?? json['created_at'];
    final deliveryAddressVal = json['deliveryAddress'] ?? json['delivery_address'] ?? '';
    final paymentMethodVal = json['paymentMethod'] ?? json['payment_method'];
    final statusVal = json['status'];
    OrderStatus statusEnum;
    if (statusVal is String) {
      switch (statusVal) {
        case 'pending':
          statusEnum = OrderStatus.pending;
          break;
        case 'confirmed':
          statusEnum = OrderStatus.confirmed;
          break;
        case 'preparing':
          statusEnum = OrderStatus.preparing;
          break;
        case 'delivery':
          statusEnum = OrderStatus.delivery;
          break;
        case 'delivered':
          statusEnum = OrderStatus.completed;
          break;
        case 'cancelled':
          statusEnum = OrderStatus.cancelled;
          break;
        default:
          statusEnum = OrderStatus.pending;
      }
    } else if (statusVal is int) {
      statusEnum = OrderStatus.values[(statusVal)];
    } else {
      statusEnum = OrderStatus.pending;
    }
    return Order(
      id: idVal ?? '',
      userId: userIdVal,
      items: orderItems,
      total: totalVal,
      orderDate: orderDateStr != null ? DateTime.parse(orderDateStr) : DateTime.now(),
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      deliveryAddress: deliveryAddressVal,
      status: statusEnum,
      paymentMethod: paymentMethodVal,
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
