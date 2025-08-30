import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? category;

  ProductsScreen({this.category});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? selectedCategory;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductService>(
        builder: (context, productService, child) {
          if (productService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          List<Product> filteredProducts;
          if (selectedCategory != null) {
            filteredProducts = productService.getProductsByCategory(selectedCategory!);
          } else {
            filteredProducts = productService.products;
          }

          if (searchQuery.isNotEmpty) {
            filteredProducts = filteredProducts.where((product) =>
            product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                product.description.toLowerCase().contains(searchQuery.toLowerCase())
            ).toList();
          }

          return Column(
            children: [
              // Filtro de categorias
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productService.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('Todos'),
                          selected: selectedCategory == null,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = null;
                            });
                          },
                          selectedColor: Colors.brown[300],
                        ),
                      );
                    }

                    final category = productService.categories[index - 1];
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? category : null;
                          });
                        },
                        selectedColor: Colors.brown[300],
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              // Grid de produtos
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(product: product);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[200],
                ),
                child: product.imageUrl.startsWith('assets/')
                    ? ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.image_not_supported, size: 50),
                  ),
                )
                    : Icon(Icons.fastfood, size: 50, color: Colors.brown),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[700],
                            fontSize: 16,
                          ),
                        ),
                        Consumer<CartService>(
                          builder: (context, cartService, child) {
                            return IconButton(
                              icon: Icon(Icons.add_shopping_cart),
                              onPressed: product.isAvailable ? () {
                                cartService.addItem(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} adicionado ao carrinho'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } : null,
                              color: Colors.brown,
                              iconSize: 20,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer<ProductService>(
      builder: (context, productService, child) {
        final results = productService.searchProducts(query);

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return ProductCard(product: results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer<ProductService>(
      builder: (context, productService, child) {
        final suggestions = query.isEmpty
            ? productService.featuredProducts
            : productService.searchProducts(query);

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final product = suggestions[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Icon(Icons.fastfood, color: Colors.brown),
              ),
              title: Text(product.name),
              subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}