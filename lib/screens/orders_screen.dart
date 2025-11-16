import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/auth_laravel_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pedidos'),
        backgroundColor: Colors.brown,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Ativos',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Histórico',
            ),
          ],
        ),
      ),
      body: Consumer2<OrderService, AuthLaravelService>(
        builder: (context, orderService, authService, child) {
          if (!authService.isAuthenticated) {
            return _buildNotAuthenticated();
          }

          if (orderService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildActiveOrders(orderService),
              _buildOrderHistory(orderService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotAuthenticated() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Faça login para ver seus pedidos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Fazer Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrders(OrderService orderService) {
    final activeOrders = orderService.orders
        .where((order) => [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.delivery,
    ].contains(order.status))
        .toList();

    if (activeOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pending_actions,
        title: 'Nenhum pedido ativo',
        subtitle: 'Seus pedidos em andamento aparecerão aqui',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final auth = Provider.of<AuthLaravelService>(context, listen: false);
        if (auth.currentUser != null) {
          await orderService.refreshOrdersForUser(auth.currentUser!.id);
        } else {
          await orderService.refreshOrders();
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) {
          final order = activeOrders[index];
          return OrderCard(
            order: order,
            showStatus: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderHistory(OrderService orderService) {
    final historyOrders = orderService.orders
        .where((order) => [
      OrderStatus.completed,
      OrderStatus.cancelled,
    ].contains(order.status))
        .toList();

    if (historyOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'Nenhum pedido no histórico',
        subtitle: 'Seus pedidos finalizados aparecerão aqui',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await orderService.refreshOrders();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: historyOrders.length,
        itemBuilder: (context, index) {
          final order = historyOrders[index];
          return OrderCard(
            order: order,
            showStatus: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final bool showStatus;
  final VoidCallback onTap;

  OrderCard({
    required this.order,
    this.showStatus = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do pedido
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${order.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showStatus)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(order.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        order.statusText,
                        style: TextStyle(
                          color: _getStatusColor(order.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12),

              // Informações do pedido
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    order.formattedOrderDate,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.delivery_dining, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Entrega: ${order.formattedDeliveryDate}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              if (order.isRecurring) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.repeat, size: 16, color: Colors.blue[600]),
                    SizedBox(width: 8),
                    Text(
                      'Pedido recorrente',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12),

              // Itens do pedido (resumo)
              Text(
                'Itens: ${order.items.map((item) => '${item.quantity}x ${item.product.name}').join(', ')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 12),

              // Total e ação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: R\$ ${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Ver detalhes',
                        style: TextStyle(
                          color: Colors.brown[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.brown[600],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
}