import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:padaria_app/models/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: ListTile(
        leading: Image.asset(
          product.imageUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback for image load errors
            return const Icon(Icons.bakery_dining_outlined, size: 50);
          },
        ),
        title: Text(product.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          'R\$ ${product.price.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart, color: Colors.brown),
          onPressed: () {
            // TODO: Implement add to cart functionality
            // You'll likely use Provider.of<CartService>(context, listen: false).addItem(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} adicionado ao carrinho (funcionalidade pendente)')),
            );
          },
        ),
        onTap: () {
          // TODO: Navigate to ProductDetailScreen if you have one
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ProductScreen(product: product), // Assuming ProductScreen is your detail screen
          //   ),
          // );
          print('Tapped on ${product.name}');
        },
      ),
    );
  }
}