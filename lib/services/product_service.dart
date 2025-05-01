import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductService with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  
  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  
  List<Product> get featuredProducts => 
      _products.where((product) => product.isFeatured).toList();
      
  List<String> get categories {
    final Set<String> categoriesSet = {};
    for (var product in _products) {
      categoriesSet.add(product.category);
    }
    return categoriesSet.toList()..sort();
  }
  
  // Inicializa com dados de exemplo
  ProductService() {
    _loadProducts();
  }
  
  // Simulação de carregamento de produtos
  Future<void> _loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    // Simula chamada de API
    await Future.delayed(Duration(seconds: 1));
    
    // Dados simulados de produtos
    _products = [
      Product(
        id: '1',
        name: 'Pão Francês',
        description: 'Pão francês tradicional, fresco e crocante.',
        price: 1.50,
        imageUrl: 'assets/images/pao_frances.jpg',
        category: 'Pães',
        isFeatured: true,
      ),
      Product(
        id: '2',
        name: 'Pão de Queijo',
        description: 'Pão de queijo mineiro, quentinho e macio.',
        price: 2.50,
        imageUrl: 'assets/images/pao_queijo.jpg',
        category: 'Pães',
        isFeatured: true,
      ),
      Product(
        id: '3',
        name: 'Croissant',
        description: 'Croissant amanteigado e folhado.',
        price: 5.00,
        imageUrl: 'assets/images/croissant.jpg',
        category: 'Doces',
        isFeatured: false,
      ),
      Product(
        id: '4',
        name: 'Bolo de Chocolate',
        description: 'Bolo de chocolate com cobertura de brigadeiro.',
        price: 30.00,
        imageUrl: 'assets/images/bolo_chocolate.jpg',
        category: 'Bolos',
        isFeatured: true,
      ),
      Product(
        id: '5',
        name: 'Café Espresso',
        description: 'Café espresso forte e aromático.',
        price: 4.50,
        imageUrl: 'assets/images/cafe.jpg',
        category: 'Bebidas',
        isFeatured: false,
      ),
      Product(
        id: '6',
        name: 'Suco de Laranja',
        description: 'Suco de laranja natural, feito na hora.',
        price: 6.00,
        imageUrl: 'assets/images/suco_laranja.jpg',
        category: 'Bebidas',
        isFeatured: false,
      ),
      Product(
        id: '7',
        name: 'Sanduíche Natural',
        description: 'Sanduíche natural com frango, cenoura, milho e maionese.',
        price: 8.50,
        imageUrl: 'assets/images/sanduiche.jpg',
        category: 'Lanches',
        isFeatured: true,
      ),
      Product(
        id: '8',
        name: 'Coxinha',
        description: 'Coxinha de frango cremosa e crocante.',
        price: 4.00,
        imageUrl: 'assets/images/coxinha.jpg',
        category: 'Salgados',
        isFeatured: false,
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> refreshProducts() async {
    await _loadProducts();
  }
  
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
  
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return [];
    
    final queryLower = query.toLowerCase();
    return _products.where((product) => 
      product.name.toLowerCase().contains(queryLower) || 
      product.description.toLowerCase().contains(queryLower)
    ).toList();
  }
}
