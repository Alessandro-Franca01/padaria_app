import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription_plan_preview.dart';
import '../services/subscription_service.dart';
import '../models/subscription_plan.dart';
import 'plan_details_screen.dart';
import 'plans_screen.dart';

class SubscriptionPlansListScreen extends StatelessWidget {
  const SubscriptionPlansListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myPlans = context.watch<SubscriptionService>().userPlans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos de Assinatura'),
        backgroundColor: Colors.brown,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PlansScreen()),
              );
            },
            child: const Text(
              'Criar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Catálogo de Planos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: subscriptionPlanPreviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final plan = subscriptionPlanPreviews[index];
                return _CatalogPlanCard(plan: plan);
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meus Planos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              Text(
                '${myPlans.length}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (myPlans.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Você ainda não tem planos.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text('Crie um plano para receber entregas recorrentes.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PlansScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                      child: const Text('Criar plano'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...myPlans.map((p) => _MyPlanTile(plan: p)).toList(),
        ],
      ),
    );
  }
}

class _CatalogPlanCard extends StatelessWidget {
  final SubscriptionPlanPreview plan;

  const _CatalogPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PlansScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      plan.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  plan.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  'R\$ ${plan.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.brown[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyPlanTile extends StatelessWidget {
  final SubscriptionPlan plan;

  const _MyPlanTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    final total = plan.items.fold<double>(0, (sum, i) => sum + i.totalPrice);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: plan.active ? Colors.green[50] : Colors.grey[200],
          child: Icon(
            plan.active ? Icons.check_circle : Icons.pause_circle_filled,
            color: plan.active ? Colors.green[700] : Colors.grey[700],
          ),
        ),
        title: Text(
          plan.id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${plan.days.join(', ')} • ${plan.time} • R\$ ${total.toStringAsFixed(2)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlanDetailsScreen(plan: plan)),
          );
        },
      ),
    );
  }
}

