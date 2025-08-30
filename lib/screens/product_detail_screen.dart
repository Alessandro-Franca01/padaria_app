import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: widget.product.imageUrl.startsWith('assets/')
                  ? Image.asset(
                widget.product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 100),
              )
                  : Icon(Icons.fastfood, size: 100, color: Colors.brown),
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
                      Text(
                        'R\$ ${widget.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Categoria
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.category,
                      style: TextStyle(
                        color: Colors.brown[700],
                        fontWeight: FontWeight.w500,
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
                      color: Colors.grey[700],
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
                      IconButton(
                        onPressed: quantity > 1 ? () {
                          setState(() {
                            quantity--;
                          });
                        } : null,
                        icon: Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
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
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.brown[200],
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Total: R\$ ${(widget.product.price * quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
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
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Consumer<CartService>(
                      builder: (context, cartService, child) {
                        return ElevatedButton.icon(
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
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pop(context);
                          } : null,
                          icon: Icon(Icons.add_shopping_cart),
                          label: Text(
                            widget.product.isAvailable
                                ? 'Adicionar ao Carrinho'
                                : 'Produto Indisponível',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.product.isAvailable
                                ? Colors.brown[700]
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Botão de ver carrinho
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Consumer<CartService>(
                      builder: (context, cartService, child) {
                        return OutlinedButton.icon(
                          onPressed: () {
                            // Navegar para o carrinho
                            Navigator.pushNamed(context, '/cart');
                          },
                          icon: Badge(
                            isLabelVisible: cartService.itemCount > 0,
                            label: Text(cartService.itemCount.toString()),
                            child: Icon(Icons.shopping_cart),
                          ),
                          label: Text(
                            'Ver Carrinho (${cartService.itemCount})',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.brown[700],
                            side: BorderSide(color: Colors.brown[700]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
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