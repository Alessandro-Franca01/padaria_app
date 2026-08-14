import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/loyalty_benefit.dart';
import '../models/loyalty_transaction.dart';
import '../services/loyalty_service.dart';
import '../theme/app_theme.dart';

class LoyaltyScreen extends StatefulWidget {
  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loyaltyService = Provider.of<LoyaltyService>(context, listen: false);
      loyaltyService.fetchStatus();
      loyaltyService.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fidelidade')),
      body: Consumer<LoyaltyService>(
        builder: (context, loyaltyService, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await loyaltyService.fetchStatus();
              await loyaltyService.fetchTransactions();
            },
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildBalanceCard(loyaltyService),
                SizedBox(height: 24),
                Text('Benefícios disponíveis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Escolha um desses benefícios no checkout ao finalizar seu próximo pedido.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: 12),
                if (loyaltyService.isLoading)
                  Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (loyaltyService.benefits.isEmpty)
                  _buildEmptyState('Nenhum benefício disponível no momento.')
                else
                  ...loyaltyService.benefits.map((benefit) => _buildBenefitTile(benefit, loyaltyService.points)),
                SizedBox(height: 24),
                Text('Histórico de pontos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                if (loyaltyService.transactions.isEmpty)
                  _buildEmptyState('Nenhuma movimentação registrada ainda.')
                else
                  ...loyaltyService.transactions.map(_buildTransactionTile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(LoyaltyService loyaltyService) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.star, color: Colors.amber[700], size: 40),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${loyaltyService.points} pontos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Saldo atual de fidelidade',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitTile(LoyaltyBenefit benefit, int currentPoints) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.card_giftcard,
          color: benefit.available ? AppColors.success : Theme.of(context).colorScheme.outline,
        ),
        title: Text(benefit.name),
        subtitle: Text(benefit.effectSummary),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${benefit.requiredPoints} pts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (!benefit.available)
              Text(
                'faltam ${benefit.requiredPoints - currentPoints}',
                style: TextStyle(fontSize: 12, color: AppColors.warning),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(LoyaltyTransaction transaction) {
    final isPositive = transaction.points > 0;
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          color: isPositive ? AppColors.success : Colors.red[600],
        ),
        title: Text(transaction.benefitName ?? transaction.typeLabel),
        subtitle: Text(
          '${transaction.description ?? transaction.typeLabel} · ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt)}',
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}${transaction.points}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPositive ? AppColors.success : Colors.red[600],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
