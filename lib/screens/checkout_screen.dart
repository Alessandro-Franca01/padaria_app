import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/loyalty_service.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryAddressController = TextEditingController();
  final _observationsController = TextEditingController();

  String _selectedPaymentMethod = 'dinheiro';
  DateTime? _selectedDeliveryDate;
  TimeOfDay? _selectedDeliveryTime;
  bool _useCurrentAddress = true;
  bool _isRecurring = false;
  List<String> _selectedRecurringDays = [];

  final List<String> _paymentMethods = [
    'dinheiro',
    'cartao_debito',
    'cartao_credito',
    'pix',
  ];

  final Map<String, String> _paymentMethodLabels = {
    'dinheiro': 'Dinheiro',
    'cartao_debito': 'Cartão de Débito',
    'cartao_credito': 'Cartão de Crédito',
    'pix': 'PIX',
  };

  final List<String> _weekDays = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      _deliveryAddressController.text = authService.currentUser!.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finalizar Compra'),
        backgroundColor: Colors.brown,
      ),
      body: Consumer3<CartService, AuthService, LoyaltyService>(
        builder: (context, cartService, authService, loyaltyService, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo do pedido
                  _buildOrderSummary(cartService),

                  SizedBox(height: 24),

                  // Endereço de entrega
                  _buildDeliveryAddress(authService),

                  SizedBox(height: 24),

                  // Data e hora de entrega
                  _buildDeliveryDateTime(),

                  SizedBox(height: 24),

                  // Pedido recorrente
                  _buildRecurringOrder(),

                  SizedBox(height: 24),

                  // Forma de pagamento
                  _buildPaymentMethod(),

                  SizedBox(height: 24),

                  // Programa de fidelidade
                  _buildLoyaltyProgram(loyaltyService, cartService.totalAmount),

                  SizedBox(height: 24),

                  // Observações
                  _buildObservations(),

                  SizedBox(height: 32),

                  // Botão de finalizar
                  _buildFinishButton(cartService, authService, loyaltyService),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartService cartService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...cartService.items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${item.quantity}x ${item.product.name}'),
                  ),
                  Text('R\$ ${item.totalPrice.toStringAsFixed(2)}'),
                ],
              ),
            )).toList(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'R\$ ${cartService.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddress(AuthService authService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Endereço de Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            if (authService.currentUser != null)
              CheckboxListTile(
                title: Text('Usar endereço cadastrado'),
                subtitle: Text(authService.currentUser!.address),
                value: _useCurrentAddress,
                onChanged: (value) {
                  setState(() {
                    _useCurrentAddress = value!;
                    if (_useCurrentAddress) {
                      _deliveryAddressController.text = authService.currentUser!.address;
                    } else {
                      _deliveryAddressController.clear();
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            if (!_useCurrentAddress)
              TextFormField(
                controller: _deliveryAddressController,
                decoration: InputDecoration(
                  labelText: 'Endereço completo',
                  hintText: 'Rua, número, bairro, cidade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o endereço de entrega';
                  }
                  return null;
                },
                maxLines: 2,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDateTime() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data e Hora de Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDeliveryDate(),
                    icon: Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDeliveryDate != null
                          ? '${_selectedDeliveryDate!.day}/${_selectedDeliveryDate!.month}/${_selectedDeliveryDate!.year}'
                          : 'Selecionar Data',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.brown[700],
                      side: BorderSide(color: Colors.brown[300]!),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDeliveryTime(),
                    icon: Icon(Icons.access_time),
                    label: Text(
                      _selectedDeliveryTime != null
                          ? '${_selectedDeliveryTime!.hour}:${_selectedDeliveryTime!.minute.toString().padLeft(2, '0')}'
                          : 'Selecionar Hora',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.brown[700],
                      side: BorderSide(color: Colors.brown[300]!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringOrder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pedido Recorrente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Receba seus produtos favoritos automaticamente nos dias selecionados',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            SwitchListTile(
              title: Text('Ativar pedido recorrente'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                  if (!_isRecurring) {
                    _selectedRecurringDays.clear();
                  }
                });
              },
              activeColor: Colors.brown[700],
            ),
            if (_isRecurring) ...[
              SizedBox(height: 12),
              Text(
                'Selecione os dias da semana:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                children: _weekDays.map((day) {
                  final isSelected = _selectedRecurringDays.contains(day);
                  return Padding(
                    padding: EdgeInsets.only(right: 8, bottom: 8),
                    child: FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedRecurringDays.add(day);
                          } else {
                            _selectedRecurringDays.remove(day);
                          }
                        });
                      },
                      selectedColor: Colors.brown[300],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forma de Pagamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ..._paymentMethods.map((method) {
              return RadioListTile<String>(
                title: Text(_paymentMethodLabels[method]!),
                value: method,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                activeColor: Colors.brown[700],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyProgram(LoyaltyService loyaltyService, double totalAmount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Programa de Fidelidade',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Pontos disponíveis: ${loyaltyService.loyaltyPoints}'),
            SizedBox(height: 8),
            Text(
              'Com esta compra você ganhará: ${(totalAmount / 5).round()} pontos',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservations() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observações do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _observationsController,
              decoration: InputDecoration(
                hintText: 'Informações adicionais para o estabelecimento...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton(CartService cartService, AuthService authService, LoyaltyService loyaltyService) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _finishOrder(cartService, authService, loyaltyService),
        icon: Icon(Icons.check_circle),
        label: Text(
          'Finalizar Pedido',
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white30,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.brown[700]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDeliveryDate = picked;
      });
    }
  }

  Future<void> _selectDeliveryTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.brown[700]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDeliveryTime = picked;
      });
    }
  }

  Future<void> _finishOrder(CartService cartService, AuthService authService, LoyaltyService loyaltyService) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDeliveryDate == null || _selectedDeliveryTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecione data e hora de entrega'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isRecurring && _selectedRecurringDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione pelo menos um dia para o pedido recorrente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Criar o pedido
    final deliveryDateTime = DateTime(
      _selectedDeliveryDate!.year,
      _selectedDeliveryDate!.month,
      _selectedDeliveryDate!.day,
      _selectedDeliveryTime!.hour,
      _selectedDeliveryTime!.minute,
    );

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authService.currentUser!.id,
      items: cartService.items,
      total: cartService.totalAmount,
      orderDate: DateTime.now(),
      deliveryDate: deliveryDateTime,
      deliveryAddress: _deliveryAddressController.text.trim(),
      paymentMethod: _paymentMethodLabels[_selectedPaymentMethod],
      isRecurring: _isRecurring,
      recurringDays: _isRecurring ? _selectedRecurringDays : null,
    );

    // Adicionar pontos de fidelidade
    final pointsEarned = (cartService.totalAmount / 5).round();
    loyaltyService.addPoints(pointsEarned);

    // Limpar carrinho
    cartService.clear();

    // Navegar para tela de confirmação
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          order: order,
          pointsEarned: pointsEarned,
        ),
      ),
    );
  }
}