import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../models/discount.dart';
import '../services/cart_service.dart';
import '../services/category_service.dart';
import '../services/discount_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../widgets/product_image.dart';
import '../widgets/remote_or_asset_image.dart';
import '../widgets/discount_navigation.dart';
import 'products_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'package:padaria_app/models/order.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'subscription_plans_list_screen.dart';
import 'discounts_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  /// Título de seção padronizado da Home.
  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildDiscountItem(Discount discount) {
    return Expanded(
      child: GestureDetector(
        onTap: () => navigateToDiscountTarget(context, discount),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: RemoteOrAssetImage(path: discount.imagePath),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  discount.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Padaria App'),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(),
                ),
              );
            },
          ),
          // Ícone do carrinho com badge
          Consumer<CartService>(
            builder: (context, cartService, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cartService.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartService.itemCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Página inicial
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Bem-vindo! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 6),
                Text(
                  'Descubra os principais produtos e ofertas!',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 20),

                // Botão Ver Todos os Produtos
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.storefront_outlined),
                  label: Text('Ver Todos os Produtos'),
                ),

                SizedBox(height: 28),

                // Seção Destaques
                _sectionTitle(context, 'Destaques'),
                SizedBox(height: 12),
                Consumer<ProductService>(
                  builder: (context, productService, child) {
                    final featured = productService.featuredProducts;
                    if (featured.isEmpty) return SizedBox.shrink();

                    return CarouselSlider.builder(
                      itemCount: featured.length,
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final product = featured[index];
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
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ProductImage(product: product),
                                // Gradiente para legibilidade do texto sobre a imagem
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.65),
                                      ],
                                      stops: const [0.45, 1.0],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 14,
                                  right: 14,
                                  bottom: 12,
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 28),

                // Seção Promoções
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle(context, 'Promoções e Descontos'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DiscountsScreen()),
                        );
                      },
                      child: Text('Ver todos'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Consumer<DiscountService>(
                  builder: (context, discountService, child) {
                    final discounts = discountService.discounts;
                    if (discounts.isEmpty) return SizedBox.shrink();

                    return SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (discounts.length / 3).ceil(),
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: EdgeInsets.only(right: 12),
                            child: Row(
                              children: [
                                _buildDiscountItem(discounts[index * 3]),
                                SizedBox(width: 12),
                                if (index * 3 + 1 < discounts.length)
                                  _buildDiscountItem(discounts[index * 3 + 1]),
                                SizedBox(width: 12),
                                if (index * 3 + 2 < discounts.length)
                                  _buildDiscountItem(discounts[index * 3 + 2]),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                SizedBox(height: 28),

                // Seção Categorias
                _sectionTitle(context, 'Nossas Especialidades'),
                SizedBox(height: 12),
                Consumer<CategoryService>(
                  builder: (context, categoryService, child) {
                    final categories = categoryService.categories;
                    if (categories.isEmpty) return SizedBox.shrink();

                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductsScreen(
                                  category: category.name,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
                                    child: RemoteOrAssetImage(path: category.imagePath),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    category.title ?? category.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 28),

                // Seção Assinaturas
                _sectionTitle(context, 'Assinaturas da Padaria'),
                SizedBox(height: 6),
                Text(
                  'Receba seus produtos favoritos toda semana com desconto.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionPlansListScreen(),
                      ),
                    );
                  },
                  child: Text('Ver todos os planos'),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),

          SubscriptionPlansListScreen(),

          // Página de Pedidos/Faturas
          OrdersScreen(),

          // Página do Carrinho
          CartScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: 'Planos',
          ),
          NavigationDestination(
            icon: Consumer<OrderService>(
              builder: (context, orderService, child) {
                final activeOrders = orderService.orders.where((order) => [
                  OrderStatus.pending,
                  OrderStatus.confirmed,
                  OrderStatus.preparing,
                  OrderStatus.delivery,
                ].contains(order.status)).length;

                return Badge(
                  isLabelVisible: activeOrders > 0,
                  label: Text('$activeOrders'),
                  child: Icon(Icons.receipt_long_outlined),
                );
              },
            ),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Consumer<CartService>(
              builder: (context, cartService, child) {
                return Badge(
                  isLabelVisible: cartService.itemCount > 0,
                  label: Text('${cartService.itemCount}'),
                  child: Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Carrinho',
          ),
        ],
      ),
    );
  }
}
