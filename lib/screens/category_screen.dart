import 'package:flutter/material.dart';
import 'package:padaria_app/models/product.dart'; // Assuming your Product model path
import 'package:padaria_app/models/category_item.dart'; // Assuming your CategoryItem model path
import 'package:padaria_app/widgets/ProductListItem.dart';

// You might need to import your ProductCard widget if you have one
// import 'package:padaria_app/widgets/product_card.dart';
// For now, I'll create a simple ProductListItem inline

class CategoryScreen extends StatelessWidget {
  final CategoryItem category;
  final List<Product> allProducts; // Pass all products to filter from

  const CategoryScreen({
    Key? key,
    required this.category,
    required this.allProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter products that belong to the current category
    final List<Product> categoryProducts = allProducts
        .where((product) => product.category.toLowerCase() == category.title.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        backgroundColor: Colors.brown, // Or use Theme.of(context).appBarTheme.backgroundColor
      ),
      body: categoryProducts.isEmpty
          ? Center(
        child: Text(
          'Nenhum produto encontrado para esta categoria.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: categoryProducts.length,
        itemBuilder: (context, index) {
          final product = categoryProducts[index];
          return ProductListItem(product: product);
        },
      ),
    );
  }
}