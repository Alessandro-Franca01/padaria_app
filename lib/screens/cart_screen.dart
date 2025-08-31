import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho de Compras'),
        backgroundColor: Colors.brown,
        actions: [
          Consumer<CartService>(
            builder: (context, cartService, child) {
              return cartService.itemCount > 0
                  ? IconButton(
                icon: Icon(Icons.delete_sweep),
                onPressed: () {
                  _showClearCartDialog(context, cartService);
                },
              )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.itemCount == 0) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartService.items[index];
                    return CartItemCard(
                      cartItem: cartItem,
                      onUpdateQuantity: (newQuantity) {
                        cartService.updateItemQuantity(
                          cartItem.product.id,
                          newQuantity,
                        );
                      },
                      onRemove: () {
                        cartService.removeItem(cartItem.product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${cartItem.product.name} removido do carrinho'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      onUpdateNotes: (notes) {
                        cartService.updateItemNotes(cartItem.product.id, notes);
                      },
                    );
                  },
                ),
              ),
              _buildCartSummary(context, cartService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Seu carrinho está vazio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Adicione alguns produtos deliciosos!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.shopping_bag),
            label: Text('Continuar Comprando'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartService cartService) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total de itens:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${cartService.itemCount}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'R\$ ${cartService.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Consumer<AuthService>(
              builder: (context, authService, child) {
                return ElevatedButton.icon(
                  onPressed: () {
                    if (!authService.isAuthenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Faça login para finalizar a compra'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.payment),
                  label: Text(
                    'Finalizar Compra',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
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
    );
  }

  void _showClearCartDialog(BuildContext context, CartService cartService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Limpar Carrinho'),
          content: Text('Tem certeza de que deseja remover todos os itens do carrinho?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                cartService.clear();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Carrinho limpo'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Confirmar'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}

class CartItemCard extends StatefulWidget {
  final CartItem cartItem;
  final Function(int) onUpdateQuantity;
  final VoidCallback onRemove;
  final Function(String?) onUpdateNotes;

  CartItemCard({
    required this.cartItem,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.onUpdateNotes,
  });

  @override
  _CartItemCardState createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  bool _isExpanded = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.cartItem.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem do produto
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: widget.cartItem.product.imageUrl.startsWith('assets/')
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.cartItem.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported),
                    ),
                  )
                      : Icon(Icons.fastfood, color: Colors.brown),
                ),

                SizedBox(width: 12),

                // Informações do produto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cartItem.product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'R\$ ${widget.cartItem.product.price.toStringAsFixed(
                            2)} cada',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          // Controles de quantidade
                          IconButton(
                            onPressed: widget.cartItem.quantity > 1 ? () {
                              widget.onUpdateQuantity(
                                  widget.cartItem.quantity - 1);
                            } : null,
                            icon: Icon(Icons.remove),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              minimumSize: Size(32, 32),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                widget.cartItem.quantity.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              widget.onUpdateQuantity(
                                  widget.cartItem.quantity + 1);
                            },
                            icon: Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.brown[200],
                              minimumSize: Size(32, 32),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'R\$ ${widget.cartItem.totalPrice.toStringAsFixed(
                                2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botão de remover
                IconButton(
                  onPressed: widget.onRemove,
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),

            // Área expansível para observações
            if (widget.cartItem.notes != null &&
                widget.cartItem.notes!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Observações:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.cartItem.notes!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Botão para adicionar/editar observações
            SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.edit_note,
                    size: 16,
                  ),
                  label: Text(
                    _isExpanded ? 'Fechar' : 'Observações',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.brown[600],
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),

            // Campo de observações expansível
            if (_isExpanded)
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Adicione suas observações...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _notesController.text = widget.cartItem.notes ?? '';
                            setState(() {
                              _isExpanded = false;
                            });
                          },
                          child: Text('Cancelar'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            widget.onUpdateNotes(_notesController.text
                                .trim()
                                .isEmpty
                                ? null
                                : _notesController.text.trim());
                            setState(() {
                              _isExpanded = false;
                            });
                          },
                          child: Text('Salvar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                          ),
                        ),
                      ],
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