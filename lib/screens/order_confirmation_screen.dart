import 'package:flutter/material.dart';
import '../models/order.dart';
import 'orders_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  final int pointsEarned;

  OrderConfirmationScreen({
    required this.order,
    required this.pointsEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Ícone de sucesso
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                    SizedBox(height: 32),
                    // Título
                    Text(
                      'Pedido Confirmado!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    // Subtítulo
                    Text(
                      'Seu pedido foi recebido com sucesso',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    // Card com informações do pedido
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow('Número do Pedido:', '#${order.id.substring(0, 8)}'),
                            SizedBox(height: 12),
                            _buildInfoRow('Data do Pedido:', order.formattedOrderDate),
                            SizedBox(height: 12),
                            _buildInfoRow('Entrega Prevista:', order.formattedDeliveryDate),
                            SizedBox(height: 12),
                            _buildInfoRow('Total:', 'R\$ ${order.total.toStringAsFixed(2)}'),
                            SizedBox(height: 12),
                            _buildInfoRow('Forma de Pagamento:', order.paymentMethod ?? 'Não informado'),

                            if (order.isRecurring) ...[
                              SizedBox(height: 12),
                              _buildInfoRow('Pedido Recorrente:', 'Sim'),
                              SizedBox(height: 8),
                              _buildInfoRow('Dias:', order.recurringDays?.join(', ') ?? ''),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Pontos de fidelidade ganhos
                    if (pointsEarned > 0)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[700],
                              size: 32,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Parabéns!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                  Text(
                                    'Você ganhou $pointsEarned pontos de fidelidade!',
                                    style: TextStyle(
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 32),
                    // Status do pedido
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Acompanhe seu Pedido',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Você pode acompanhar o status do seu pedido na seção "Meus Pedidos"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Botões de ação fixos no final
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrdersScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.receipt_long),
                      label: Text(
                        'Ver Meus Pedidos',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      icon: Icon(Icons.home),
                      label: Text(
                        'Voltar ao Início',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.brown[700],
                        side: BorderSide(color: Colors.brown[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}