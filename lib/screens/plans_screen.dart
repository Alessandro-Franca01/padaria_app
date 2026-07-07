import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/subscription_service.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_template.dart';
import 'plan_details_screen.dart';

class PlansScreen extends StatefulWidget {
  final SubscriptionPlan? editingPlan;
  final String? initialTemplateId;

  PlansScreen({this.editingPlan, this.initialTemplateId});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final TextEditingController _addressController = TextEditingController();
  final List<String> _weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  SubscriptionTemplate? _selectedTemplate;
  final Map<String, int> _selectedQuantities = {};
  List<String> _selectedDays = [];
  String _time = '';
  bool _active = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final subscriptionService = context.read<SubscriptionService>();
      await subscriptionService.fetchTemplates();
      if (!mounted) return;

      final editingPlan = widget.editingPlan;
      final wantedTemplateId = editingPlan?.templateId ?? widget.initialTemplateId;

      if (wantedTemplateId != null) {
        final template = subscriptionService.templates.firstWhere(
          (t) => t.id == wantedTemplateId,
          orElse: () => subscriptionService.templates.first,
        );
        setState(() => _selectedTemplate = template);
      }

      if (editingPlan != null) {
        setState(() {
          for (final item in editingPlan.items) {
            _selectedQuantities[item.product.id] = item.quantity;
          }
          _selectedDays = List<String>.from(editingPlan.days);
          _time = editingPlan.time;
          _addressController.text = editingPlan.deliveryAddress;
          _active = editingPlan.active;
        });
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final currentTime = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: currentTime);
    if (picked != null) {
      final String hh = picked.hour.toString().padLeft(2, '0');
      final String mm = picked.minute.toString().padLeft(2, '0');
      setState(() => _time = '$hh:$mm');
    }
  }

  void _useUserAddress() {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Faça login para usar o endereço salvo.')),
      );
      return;
    }

    if (user.address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum endereço salvo no perfil.')),
      );
      return;
    }

    setState(() => _addressController.text = user.address);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Endereço do perfil aplicado ao plano.')),
    );
  }

  void _selectTemplate(SubscriptionTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _selectedQuantities.clear();
    });
  }

  List<CartItem> get _currentItems {
    final products = _selectedTemplate?.products ?? [];
    return _selectedQuantities.entries
        .where((e) => e.value > 0)
        .map((e) {
          final product = products.firstWhere((p) => p.productId == e.key);
          return CartItem(
            product: Product(
              id: product.productId,
              name: product.productName,
              description: '',
              price: product.price,
              imageUrl: product.imageUrl,
              category: '',
            ),
            quantity: e.value,
          );
        })
        .toList();
  }

  Future<void> _savePlan(BuildContext context) async {
    if (_selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione um plano para continuar.')),
      );
      return;
    }

    final items = _currentItems;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione pelo menos um produto para o plano.')),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione pelo menos um dia da semana para o plano.')),
      );
      return;
    }

    if (_time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione um horário de entrega para o plano.')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe um endereço de entrega para o plano.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final subscriptionService = context.read<SubscriptionService>();
      final SubscriptionPlan result;
      if (widget.editingPlan != null) {
        result = await subscriptionService.updateSubscription(
          subscriptionId: widget.editingPlan!.id,
          items: items,
          days: _selectedDays,
          time: _time,
          deliveryAddress: _addressController.text.trim(),
          active: _active,
        );
      } else {
        result = await subscriptionService.createSubscription(
          templateId: _selectedTemplate!.id,
          items: items,
          days: _selectedDays,
          time: _time,
          deliveryAddress: _addressController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => PlanDetailsScreen(plan: result)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : 'Não foi possível salvar o plano.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTemplatePicker(List<SubscriptionTemplate> templates) {
    if (templates.isEmpty) {
      return Text('Nenhum plano disponível no momento.', style: TextStyle(color: Colors.grey[600]));
    }
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          final selected = _selectedTemplate?.id == template.id;
          return Card(
            margin: EdgeInsets.only(right: 12),
            color: selected ? Colors.brown[100] : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: selected ? Colors.brown : Colors.transparent, width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _selectTemplate(template),
              child: Container(
                width: 160,
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      template.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Text(
                      '${template.products.length} produtos disponíveis',
                      style: TextStyle(fontSize: 11, color: Colors.brown[700]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductItem(SubscriptionTemplateProduct product) {
    final quantity = _selectedQuantities[product.productId] ?? 0;
    final selected = quantity > 0;
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
                child: product.imageUrl.startsWith('assets/')
                    ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                    : Icon(Icons.fastfood, color: Colors.brown),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('R\$ ${product.price.toStringAsFixed(2)}'),
                ],
              ),
            ),
            IconButton(
              icon: Icon(selected ? Icons.check_circle : Icons.add_circle_outline, color: Colors.brown),
              onPressed: () {
                setState(() {
                  _selectedQuantities[product.productId] = selected ? 0 : 1;
                });
              },
            ),
            if (selected)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        final newQty = quantity - 1;
                        if (newQty <= 0) {
                          _selectedQuantities.remove(product.productId);
                        } else {
                          _selectedQuantities[product.productId] = newQty;
                        }
                      });
                    },
                  ),
                  Text('$quantity'),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() => _selectedQuantities[product.productId] = quantity + 1);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingPlan != null ? 'Editar Plano' : 'Plano de Assinatura'),
        backgroundColor: Colors.brown,
      ),
      body: Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Escolha um plano', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                if (subscriptionService.isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  _buildTemplatePicker(subscriptionService.templates),

                if (_selectedTemplate != null) ...[
                  SizedBox(height: 24),
                  Text('Escolha os produtos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _selectedTemplate!.products.length,
                    itemBuilder: (context, index) => _buildProductItem(_selectedTemplate!.products[index]),
                  ),
                ],

                SizedBox(height: 16),
                Text('Dias da semana'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _weekDays.map((d) {
                    final selected = _selectedDays.contains(d);
                    return ChoiceChip(
                      label: Text(d),
                      selected: selected,
                      selectedColor: Colors.brown[200],
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            if (!_selectedDays.contains(d)) _selectedDays.add(d);
                          } else {
                            _selectedDays.remove(d);
                          }
                        });
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
                        child: Text(_time.isEmpty ? 'Selecione o horário' : _time),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _pickTime,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white30),
                      child: Text('Escolher'),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('Endereço de entrega'),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: _useUserAddress,
                    icon: Icon(Icons.person_pin_circle),
                    label: Text('Usar endereço do perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white30,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: 'Rua, número, bairro, cidade',
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: _active,
                      onChanged: (v) => setState(() => _active = v),
                      activeColor: Colors.brown,
                      inactiveThumbColor: Colors.brown[200],
                      inactiveTrackColor: Colors.brown[100],
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
                        Text('Plano: ${_selectedTemplate?.name ?? '-'}'),
                        SizedBox(height: 4),
                        Text('Produtos: ${_currentItems.map((i) => '${i.product.name} x${i.quantity}').join(', ')}'),
                        SizedBox(height: 4),
                        Text('Dias: ${_selectedDays.join(', ')}'),
                        SizedBox(height: 4),
                        Text('Horário: ${_time.isEmpty ? '-' : _time}'),
                        SizedBox(height: 4),
                        Text('Endereço: ${_addressController.text.isEmpty ? '-' : _addressController.text}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _savePlan(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[200],
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: _isSaving
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Salvar Plano'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
