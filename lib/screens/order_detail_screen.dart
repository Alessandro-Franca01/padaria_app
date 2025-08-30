import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  OrderDetailScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${order.id.substring(0, 8)}'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<OrderService>(context, listen: false).refreshOrders();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status do pedido
            _buildStatusCard(),

            SizedBox(height: 16),

            // Informações do pedido
            _buildOrderInfo(),

            SizedBox(height: 16),

            // Itens do pedido
            _buildOrderItems(),

            SizedBox(height: 16),

            // Informações de entrega
            _buildDeliveryInfo(),

            SizedBox(height: 16),

            // Informações de pagamento
            _buildPaymentInfo(),

            if (order.isRecurring) ...[
              SizedBox(height: 16),
              _buildRecurringInfo(),
            ],

            SizedBox(height: 24),

            // Botões de ação
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStatusColor(order.status).withOpacity(0.1),
              _getStatusColor(order.status).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              _getStatusIcon(order.status),
              size: 50,
              color: _getStatusColor(order.status),
            ),
            SizedBox(height: 12),
            Text(
              order.statusText,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(order.status),
              ),
            ),
            SizedBox(height: 8),
            Text(
              _getStatusDescription(order.status),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Número do Pedido:', '#${order.id.substring(0, 8)}'),
            _buildInfoRow('Data do Pedido:', order.formattedOrderDate),
            _buildInfoRow('Total:', 'R\$ ${order.total.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itens do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...order.items.map((item) => Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  // Imagem do produto
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: item.product.imageUrl.startsWith('assets/')
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported),
                      ),
                    )
                        : Icon(Icons.fastfood, color: Colors.brown),
                  ),
                  SizedBox(width: 12),
                  // Informações do item
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Quantidade: ${item.quantity}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (item.notes != null && item.notes!.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            'Obs: ${item.notes}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Preço
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${item.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'R\$ ${item.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Data/Hora da Entrega:', order.formattedDeliveryDate),
            _buildInfoRow('Endereço:', order.deliveryAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Pagamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Forma de Pagamento:', order.paymentMethod ?? 'Não informado'),
            _buildInfoRow('Total Pago:', 'R\$ ${order.total.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.repeat, color: Colors.blue[600]),
                SizedBox(width: 8),
                Text(
                  'Pedido Recorrente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Status:', 'Ativo'),
            if (order.recurringDays != null)
              _buildInfoRow('Dias da Semana:', order.recurringDays!.join(', ')),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ Sobre pedidos recorrentes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Este pedido será automaticamente repetido nos dias selecionados. Você pode cancelar ou modificar a qualquer momento.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    // Botão de cancelar pedido (apenas para pedidos ativos)
    if ([OrderStatus.pending, OrderStatus.confirmed].contains(order.status)) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _showCancelDialog(context),
            icon: Icon(Icons.cancel),
            label: Text('Cancelar Pedido'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
      buttons.add(SizedBox(height: 12));
    }

    // Botão de reordenar (para pedidos concluídos)
    if (order.status == OrderStatus.completed) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _reorderItems(context),
            icon: Icon(Icons.refresh),
            label: Text('Fazer Pedido Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
      buttons.add(SizedBox(height: 12));
    }

    // Botão de suporte
    buttons.add(
      SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () => _contactSupport(context),
          icon: Icon(Icons.help_outline),
          label: Text('Entrar em Contato'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.brown[700],
            side: BorderSide(color: Colors.brown[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );

    return Column(children: buttons);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.delivery:
        return Colors.amber;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.delivery:
        return Icons.delivery_dining;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Aguardando confirmação da padaria';
      case OrderStatus.confirmed:
        return 'Pedido confirmado e será preparado em breve';
      case OrderStatus.preparing:
        return 'Seus produtos estão sendo preparados';
      case OrderStatus.delivery:
        return 'Pedido saiu para entrega';
      case OrderStatus.completed:
        return 'Pedido entregue com sucesso';
      case OrderStatus.cancelled:
        return 'Pedido foi cancelado';
      default:
        return 'Status desconhecido';
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancelar Pedido'),
          content: Text(
            'Tem certeza de que deseja cancelar este pedido? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<OrderService>(context, listen: false)
                    .updateOrderStatus(order.id, OrderStatus.cancelled);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pedido cancelado com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Sim, Cancelar'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _reorderItems(BuildContext context) {
    // Aqui você implementaria a lógica para adicionar os itens ao carrinho novamente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Itens adicionados ao carrinho!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Ver Carrinho',
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Entrar em Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Como podemos ajudar?'),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text('Telefone'),
                subtitle: Text('(11) 99999-9999'),
                onTap: () {
                  // Implementar chamada telefônica
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.message, color: Colors.blue),
                title: Text('WhatsApp'),
                subtitle: Text('(11) 99999-9999'),
                onTap: () {
                  // Implementar abertura do WhatsApp
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.orange),
                title: Text('Email'),
                subtitle: Text('contato@padaria.com'),
                onTap: () {
                  // Implementar envio de email
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}