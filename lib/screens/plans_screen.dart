import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/subscription_service.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class PlansScreen extends StatefulWidget {
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final TextEditingController _addressController = TextEditingController();
  final List<String> _weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productService = context.read<ProductService>();
      final subscription = context.read<SubscriptionService>();
      subscription.loadFromStorage(productService).then((_) {
        if (subscription.plan == null) {
          subscription.initialize('user-1');
        }
        _addressController.text = subscription.address;
      });
    });
  }

  Future<void> _pickTime() async {
    final currentTime = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: currentTime);
    if (picked != null) {
      final String hh = picked.hour.toString().padLeft(2, '0');
      final String mm = picked.minute.toString().padLeft(2, '0');
      context.read<SubscriptionService>().setTime('$hh:$mm');
    }
  }

  Widget _buildProductItem(Product product) {
    return Consumer<SubscriptionService>(
      builder: (context, sub, child) {
        final index = sub.items.indexWhere((i) => i.product.id == product.id);
        final selected = index >= 0;
        final quantity = selected ? sub.items[index].quantity : 0;
        return Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('R\$ ${product.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(selected ? Icons.check_circle : Icons.add_circle_outline, color: Colors.brown),
                  onPressed: () {
                    context.read<SubscriptionService>().toggleProduct(product);
                  },
                ),
                if (selected)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          final newQty = quantity - 1;
                          context.read<SubscriptionService>().updateQuantity(product, newQty);
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () {
                          final newQty = quantity + 1;
                          context.read<SubscriptionService>().updateQuantity(product, newQty);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plano de Assinatura'),
        backgroundColor: Colors.brown,
      ),
      body: Consumer2<ProductService, SubscriptionService>(
        builder: (context, productsService, sub, child) {
          final products = productsService.products;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Escolha os produtos'),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _buildProductItem(products[index]),
                ),
                SizedBox(height: 16),
                Text('Dias da semana'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _weekDays.map((d) {
                    final selected = sub.days.contains(d);
                    return ChoiceChip(
                      label: Text(d),
                      selected: selected,
                      selectedColor: Colors.brown[200],
                      onSelected: (val) {
                        final newDays = List<String>.from(sub.days);
                        if (val) {
                          if (!newDays.contains(d)) newDays.add(d);
                        } else {
                          newDays.remove(d);
                        }
                        context.read<SubscriptionService>().setDays(newDays);
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                Text('Horário de entrega'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(sub.time.isEmpty ? 'Selecione o horário' : sub.time),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _pickTime,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                      child: Text('Escolher'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Endereço de entrega'),
                SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: 'Rua, número, bairro, cidade',
                  ),
                  onChanged: (v) => context.read<SubscriptionService>().setAddress(v),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: sub.active,
                      onChanged: (v) => context.read<SubscriptionService>().setActive(v),
                      activeColor: Colors.brown,
                    ),
                    Text('Plano ativo'),
                  ],
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resumo'),
                        SizedBox(height: 8),
                        Text('Produtos: ${sub.items.map((i) => '${i.product.name} x${i.quantity}').join(', ')}'),
                        SizedBox(height: 4),
                        Text('Dias: ${sub.days.join(', ')}'),
                        SizedBox(height: 4),
                        Text('Horário: ${sub.time.isEmpty ? '-' : sub.time}'),
                        SizedBox(height: 4),
                        Text('Endereço: ${sub.address.isEmpty ? '-' : sub.address}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
