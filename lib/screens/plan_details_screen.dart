import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class PlanDetailsScreen extends StatelessWidget {
  final SubscriptionPlan plan;

  const PlanDetailsScreen({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Planos estáticos de exemplo
    final Product paoFrances = Product(
      id: 'p1',
      name: 'Pão Francês',
      description: 'Pão francês fresquinho',
      price: 1.50,
      imageUrl: 'assets/images/paes_artesanais.jpeg',
      category: 'Pães',
    );

    final Product boloChocolate = Product(
      id: 'd1',
      name: 'Bolo de Chocolate',
      description: 'Delicioso bolo de chocolate',
      price: 25.00,
      imageUrl: 'assets/images/categories/categoria_doces.jpeg',
      category: 'Doces',
    );

    final Product cafe = Product(
      id: 'b1',
      name: 'Café Coado',
      description: 'Café coado na hora',
      price: 5.00,
      imageUrl: 'assets/images/categories/categoria_bebidas.jpeg',
      category: 'Bebidas',
    );

    final List<SubscriptionPlan> examplePlans = [
      SubscriptionPlan(
        id: 'Cafe-da-manha',
        userId: 'user-example',
        items: [
          CartItem(product: paoFrances, quantity: 6),
          CartItem(product: cafe, quantity: 2),
        ],
        days: ['Seg', 'Qua', 'Sex'],
        time: '08:00',
        deliveryAddress: 'Av. Presidente Café Filho, 954, Bessa, João Pessoa',
        active: true,
      ),
      SubscriptionPlan(
        id: 'lanche-da-tarde',
        userId: 'user-example',
        items: [
          CartItem(product: boloChocolate, quantity: 1),
          CartItem(product: paoFrances, quantity: 4),
        ],
        days: ['Ter', 'Qui'],
        time: '15:00',
        deliveryAddress: 'Av. Presidente Café Filho, 954, Bessa, João Pessoa',
        active: false,
      ),
    ];

    // Adiciona o plano dinâmico à lista de planos a serem exibidos
    final List<SubscriptionPlan> allPlans = [plan, ...examplePlans];

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
              'Seu(s) Plano(s) de Assinatura(s)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: allPlans.length,
              itemBuilder: (context, index) {
                final currentPlan = allPlans[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0 ? 'Seu Plano Atual' : 'Plano Exemplo ${index}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                          ),
                          SizedBox(height: 8),
                          _buildDetailRow('Status:', currentPlan.active ? 'Ativo' : 'Inativo'),
                          _buildDetailRow('ID do Usuário:', currentPlan.userId),
                          _buildDetailRow('Dias de Entrega:', currentPlan.days.join(', ')),
                          _buildDetailRow('Horário de Entrega:', currentPlan.time),
                          _buildDetailRow('Endereço de Entrega:', currentPlan.deliveryAddress),
                          SizedBox(height: 16),
                          Text(
                            'Produtos:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          ...currentPlan.items.map((item) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                            child: Text('${item.product.name} x${item.quantity} (R\$ ${item.product.price.toStringAsFixed(2)} cada)'),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Volta para a tela anterior
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, // Corrigido para Colors.brown
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Voltar para Planos'),
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
