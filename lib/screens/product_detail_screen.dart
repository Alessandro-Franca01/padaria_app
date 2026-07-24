import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/product_image.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            Container(
              height: 300,
              width: double.infinity,
              color: colorScheme.surfaceContainerHighest,
              child: ProductImage(product: widget.product, iconSize: 100),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e preço
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (widget.product.hasDiscount)
                            Text(
                              'R\$ ${widget.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          Text(
                            'R\$ ${widget.product.effectivePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Categoria
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.category,
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Descrição
                  Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Quantidade
                  Text(
                    'Quantidade',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: quantity > 1 ? () {
                          setState(() {
                            quantity--;
                          });
                        } : null,
                        icon: Icon(Icons.remove),
                      ),
                      Container(
                        width: 60,
                        height: 44,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            quantity.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                      Spacer(),
                      Text(
                        'Total: R\$ ${(widget.product.effectivePrice * quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Observações
                  Text(
                    'Observações (opcional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Sem cebola, bem assado...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),

                  SizedBox(height: 32),

                  // Botão de adicionar ao carrinho
                  Consumer<CartService>(
                    builder: (context, cartService, child) {
                      return FilledButton.icon(
                        onPressed: widget.product.isAvailable ? () {
                          cartService.addItem(
                            widget.product,
                            quantity: quantity,
                            notes: notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${widget.product.name} adicionado ao carrinho (${quantity}x)',
                              ),
                              duration: Duration(seconds: 2),
                              backgroundColor: AppColors.success,
                            ),
                          );

                          Navigator.pop(context);
                        } : null,
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text(
                          widget.product.isAvailable
                              ? 'Adicionar ao Carrinho'
                              : 'Produto Indisponível',
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12),

                  // Botão de ver carrinho
                  Consumer<CartService>(
                    builder: (context, cartService, child) {
                      return OutlinedButton.icon(
                        onPressed: () {
                          // Navegar para o carrinho (usa rota explícita com MaterialPageRoute)
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartScreen()),
                          );
                        },
                        icon: Badge(
                          isLabelVisible: cartService.itemCount > 0,
                          label: Text('${cartService.itemCount}'),
                          child: Icon(Icons.shopping_cart_outlined),
                        ),
                        label: Text('Ver Carrinho (${cartService.itemCount})'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}