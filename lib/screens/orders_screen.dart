import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.isAuthenticated) {
        Provider.of<OrderService>(context, listen: false).fetchOrders(authService.currentUser!.id);
      }
    });
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
        bottom: TabBar(
          controller: _tabController,
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
      body: Consumer2<OrderService, AuthService>(
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
              _buildActiveOrders(orderService, authService),
              _buildOrderHistory(orderService, authService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotAuthenticated() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  size: 72,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: 20),
                Text(
                  'Faça login para ver seus pedidos',
                  style: TextStyle(
                    fontSize: 17,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Fazer Login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveOrders(OrderService orderService, AuthService authService) {
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
        await orderService.fetchOrders(authService.currentUser!.id);
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

  Widget _buildOrderHistory(OrderService orderService, AuthService authService) {
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
        await orderService.fetchOrders(authService.currentUser!.id);
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
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 56,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
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
                  Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text(
                    order.formattedOrderDate,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.delivery_dining, size: 16, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Entrega: ${order.formattedDeliveryDate}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                  color: colorScheme.onSurfaceVariant,
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
                      color: colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Ver detalhes',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: colorScheme.primary,
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