import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../widgets/product_image.dart';
import '../theme/app_theme.dart';
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
    // Fetch products when the screen initializes
    //Provider.of<ProductService>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos'),
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
    final colorScheme = Theme.of(context).colorScheme;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                color: colorScheme.surfaceContainerHighest,
                child: ProductImage(
                  product: product,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                    SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.hasDiscount)
                                Text(
                                  'R\$ ${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                'R\$ ${product.effectivePrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4),
                        Consumer<CartService>(
                          builder: (context, cartService, child) {
                            return Material(
                              color: product.isAvailable
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: product.isAvailable ? () {
                                  cartService.addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} adicionado ao carrinho'),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } : null,
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Icon(
                                    Icons.add_shopping_cart,
                                    color: product.isAvailable
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                              ),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Icon(Icons.fastfood, color: Theme.of(context).colorScheme.primary),
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