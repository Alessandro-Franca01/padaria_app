import 'package:flutter/material.dart';

import '../models/discount.dart';
import '../screens/plans_screen.dart';
import '../screens/product_detail_screen.dart';

void navigateToDiscountTarget(BuildContext context, Discount discount) {
  if (discount.targetType == DiscountTargetType.product && discount.product != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailScreen(product: discount.product!)),
    );
  } else if (discount.targetType == DiscountTargetType.subscription && discount.subscriptionTemplate != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlansScreen(initialTemplateId: discount.subscriptionTemplate!.id)),
    );
  }
}
