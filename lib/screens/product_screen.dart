import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class ProductScreen extends StatelessWidget {
  final Product product;
  const ProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.brown, // Consider moving to theme
      ),
      body: _ProductDetails(product: product),
      bottomNavigationBar: _AddToCartButton(product: product),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final Product product;

  const _ProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            product.imageUrl,
            height: 250,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.brown[700], // Consider moving to theme
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final Product product;

  const _AddToCartButton({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use context.read for one-off method calls if not listening
    final cart = context.read<CartService>();
    // Or, if this button needs to change based on cart state (e.g., disable if item already in cart)
    // final cart = context.watch<CartService>();
    // final isInCart = cart.isItemInCart(product); // Example

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Adicionar ao Carrinho'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[700], // Consider moving to theme
        ),
        onPressed: () {
          // if (isInCart) return; // Example conditional logic
          cart.addItem(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} adicionado ao carrinho'),
              duration: const Duration(seconds: 2), // Good practice to set duration
            ),
          );
        },
      ),
    );
  }
}