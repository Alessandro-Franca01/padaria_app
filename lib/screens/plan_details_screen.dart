import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';

class PlanDetailsScreen extends StatelessWidget {
  final SubscriptionPlan plan;

  const PlanDetailsScreen({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = plan.items.fold<double>(0, (sum, i) => sum + i.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Plano'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plano de Assinatura',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.id,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow('Status:', plan.active ? 'Ativo' : 'Inativo'),
                    _buildDetailRow('ID do Usuário:', plan.userId),
                    _buildDetailRow('Dias de Entrega:', plan.days.join(', ')),
                    _buildDetailRow('Horário de Entrega:', plan.time),
                    _buildDetailRow('Endereço de Entrega:', plan.deliveryAddress),
                    _buildDetailRow('Total estimado:', 'R\$ ${total.toStringAsFixed(2)}'),
                    SizedBox(height: 16),
                    Text(
                      'Produtos:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ...plan.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: Text(
                          '${item.product.name} x${item.quantity} (R\$ ${item.product.price.toStringAsFixed(2)} cada)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Volta para a tela anterior
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade200, // cor mais clara
                  foregroundColor: Colors.brown.shade900, // texto com bom contras                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                // TODO: Alterar a cor do botão para cor mais clara
                child: Text('Voltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
