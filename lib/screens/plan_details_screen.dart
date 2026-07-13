import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';
import 'plans_screen.dart';

class PlanDetailsScreen extends StatelessWidget {
  final SubscriptionPlan plan;

  const PlanDetailsScreen({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Plano'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => PlansScreen(editingPlan: plan)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plano de Assinatura',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.templateName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow('Status:', plan.active ? 'Ativo' : 'Inativo'),
                    _buildDetailRow('Dias de Entrega:', plan.days.join(', ')),
                    _buildDetailRow('Horário de Entrega:', plan.time),
                    _buildDetailRow('Endereço de Entrega:', plan.deliveryAddress),
                    _buildDetailRow('Total estimado:', 'R\$ ${plan.totalPrice.toStringAsFixed(2)}'),
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Volta para a tela anterior
                },
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
