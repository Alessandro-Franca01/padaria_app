import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/discount.dart';
import '../services/discount_service.dart';
import '../widgets/discount_navigation.dart';
import '../widgets/remote_or_asset_image.dart';
import '../theme/app_theme.dart';

class DiscountsScreen extends StatelessWidget {
  const DiscountsScreen({super.key});

  String _formatPrice(double value) => 'R\$ ${value.toStringAsFixed(2)}';

  String? _targetName(Discount discount) {
    if (discount.targetType == DiscountTargetType.product) return discount.product?.name;
    return discount.subscriptionTemplate?.name;
  }

  double? _fullPrice(Discount discount) {
    if (discount.targetType == DiscountTargetType.product) return discount.product?.price;
    return discount.subscriptionTemplate?.price;
  }

  double? _effectivePrice(Discount discount) {
    if (discount.targetType == DiscountTargetType.product) return discount.product?.effectivePrice;
    return discount.subscriptionTemplate?.effectivePrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promoções e Descontos')),
      body: Consumer<DiscountService>(
        builder: (context, discountService, child) {
          if (discountService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final discounts = discountService.discounts;
          if (discounts.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma promoção disponível no momento.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: discounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _DiscountCard(
              discount: discounts[index],
              targetName: _targetName(discounts[index]),
              fullPrice: _fullPrice(discounts[index]),
              effectivePrice: _effectivePrice(discounts[index]),
              formatPrice: _formatPrice,
            ),
          );
        },
      ),
    );
  }
}

class _DiscountCard extends StatelessWidget {
  final Discount discount;
  final String? targetName;
  final double? fullPrice;
  final double? effectivePrice;
  final String Function(double) formatPrice;

  const _DiscountCard({
    required this.discount,
    required this.targetName,
    required this.fullPrice,
    required this.effectivePrice,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => navigateToDiscountTarget(context, discount),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: RemoteOrAssetImage(path: discount.imagePath),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Text(
                            '-${discount.percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      discount.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (targetName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        targetName!,
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (fullPrice != null && effectivePrice != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            formatPrice(fullPrice!),
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatPrice(effectivePrice!),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
