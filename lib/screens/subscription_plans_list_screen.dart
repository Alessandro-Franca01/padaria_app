import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/subscription_service.dart';
import '../services/auth_service.dart';
import '../models/subscription_template.dart';
import '../models/subscription_plan.dart';
import 'plan_details_screen.dart';
import 'plans_screen.dart';

class SubscriptionPlansListScreen extends StatefulWidget {
  const SubscriptionPlansListScreen({super.key});

  @override
  State<SubscriptionPlansListScreen> createState() => _SubscriptionPlansListScreenState();
}

class _SubscriptionPlansListScreenState extends State<SubscriptionPlansListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subscriptionService = context.read<SubscriptionService>();
      subscriptionService.fetchTemplates();
      final authService = context.read<AuthService>();
      if (authService.isAuthenticated) {
        subscriptionService.fetchUserPlans(authService.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionService = context.watch<SubscriptionService>();
    final templates = subscriptionService.templates;
    final myPlans = subscriptionService.userPlans;

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
          if (subscriptionService.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (templates.isEmpty)
            Text('Nenhum plano disponível no momento.', style: TextStyle(color: Colors.grey[600]))
          else
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return _TemplateCard(template: template);
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

class _TemplateCard extends StatelessWidget {
  final SubscriptionTemplate template;

  const _TemplateCard({required this.template});

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
              MaterialPageRoute(builder: (_) => PlansScreen(initialTemplateId: template.id)),
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
                    child: template.imagePath.startsWith('assets/')
                        ? Image.asset(template.imagePath, fit: BoxFit.cover, width: double.infinity)
                        : Container(color: Colors.brown[50]),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  template.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  template.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '${template.products.length} produtos disponíveis',
                  style: TextStyle(
                    color: Colors.brown[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
          plan.templateName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${plan.days.join(', ')} • ${plan.time} • R\$ ${plan.totalPrice.toStringAsFixed(2)}',
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
