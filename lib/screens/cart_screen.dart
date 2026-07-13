import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';
import 'products_screen.dart';

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
                            backgroundColor: Theme.of(context).colorScheme.error,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Seu carrinho está vazio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione alguns produtos deliciosos!',
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                }
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(),
                  ),
                );
              },
              icon: Icon(Icons.shopping_bag_outlined),
              label: Text('Continuar Comprando'),
            ),
          ],
        ),
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Consumer<AuthService>(
            builder: (context, authService, child) {
              return FilledButton.icon(
                onPressed: () {
                  if (!authService.isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Faça login para finalizar a compra'),
                        backgroundColor: AppColors.warning,
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
                label: Text('Finalizar Compra'),
              );
            },
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
                    backgroundColor: AppColors.success,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.only(bottom: 12),
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
                    borderRadius: BorderRadius.circular(10),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: widget.cartItem.product.imageUrl.startsWith('assets/')
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.cartItem.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported),
                    ),
                  )
                      : Icon(Icons.fastfood, color: colorScheme.primary),
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
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          // Controles de quantidade
                          IconButton.filledTonal(
                            onPressed: widget.cartItem.quantity > 1 ? () {
                              widget.onUpdateQuantity(
                                  widget.cartItem.quantity - 1);
                            } : null,
                            icon: Icon(Icons.remove),
                            constraints: BoxConstraints.tightFor(width: 36, height: 36),
                            padding: EdgeInsets.zero,
                          ),
                          Container(
                            width: 44,
                            height: 36,
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                widget.cartItem.quantity.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton.filled(
                            onPressed: () {
                              widget.onUpdateQuantity(
                                  widget.cartItem.quantity + 1);
                            },
                            icon: Icon(Icons.add),
                            constraints: BoxConstraints.tightFor(width: 36, height: 36),
                            padding: EdgeInsets.zero,
                          ),
                          Spacer(),
                          Text(
                            'R\$ ${widget.cartItem.totalPrice.toStringAsFixed(
                                2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
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
                  icon: Icon(Icons.delete_outline),
                  color: colorScheme.error,
                ),
              ],
            ),

            // Área expansível para observações
            if (widget.cartItem.notes != null &&
                widget.cartItem.notes!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                        color: colorScheme.onSurfaceVariant,
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
                        FilledButton(
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
                          style: FilledButton.styleFrom(
                            minimumSize: Size(0, 40),
                          ),
                          child: Text('Salvar'),
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