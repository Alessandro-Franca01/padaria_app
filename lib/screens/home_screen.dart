import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:padaria_app/models/category_item.dart';
import 'package:padaria_app/models/discount_item.dart';

import '../widgets/CarouselCard.dart';
import '../screens/product_screen.dart';

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

  Widget _buildDiscountItem(DiscountItem discount) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        print('Tag selecionada: ${discount.description}');
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  discount.imagePath,
                  height: 60,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 4),
              Text(
                discount.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
        backgroundColor: Colors.brown,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Página inicial (substituindo o 'Meus Dados')
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção 3+12 (Header)
                Text(
                  'Home Page',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(height: 16),

                // Seção Navigation
                Text(
                  'Descubra os principais produtos e ofertas!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                    // Dentro do Column do body (substitua o Card atual):
                    Column(
                    children: [
                    SizedBox(height: 16),
                    Text(
                      'Destaques',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 12),
                    CarouselSlider.builder(
                      itemCount: carouselItems.length,
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final item = carouselItems[index];
                        return GestureDetector(
                          onTap: () {
                            if (item.product != null) {
                              // Navegar para a tela do produto
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductScreen(product: item.product!),
                                ),
                              );
                            } else if (item.category != null) {
                              // Navegar para a tela da categoria
                              print('Categoria selecionada: ${item.category!.title}');
                            }
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.asset(
                                    item.imagePath,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),

                // Seção 1+12 Settings
                Text(
                  'Nossas promoções que só tem aqui no App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'Promoções e Descontos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150, // Altura fixa para a lista
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: (DiscountItems.length / 3).ceil(), // 3 itens por "página"
                            itemBuilder: (context, index) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.9, // Largura do container
                                margin: EdgeInsets.only(right: 12),
                                child: Row(
                                  children: [
                                    // Item 1
                                    _buildDiscountItem(DiscountItems[index * 3]),
                                    SizedBox(width: 12),
                                    // Item 2 (se existir)
                                    if (index * 3 + 1 < DiscountItems.length)
                                      _buildDiscountItem(DiscountItems[index * 3 + 1]),
                                    SizedBox(width: 12),
                                    // Item 3 (se existir)
                                    if (index * 3 + 2 < DiscountItems.length)
                                      _buildDiscountItem(DiscountItems[index * 3 + 2]),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),

                // Seção Drop by Category
                Text(
                  'Escolha uma de nossas categorias especializadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Categorias',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(), // Para scroll no pai
                      shrinkWrap: true,
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 colunas
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8, // Proporção imagem/título
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Ação ao clicar
                            print('Categoria selecionada: ${categories[index].title}');
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.asset(
                                    categories[index].imagePath,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    categories[index].title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
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
          Center(child: Text('Faturas')),
          Center(child: Text('Carrinho de Compras')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Mudei para ícone de home
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Faturas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrinho',
          ),
        ],
        selectedItemColor: Colors.brown,
      ),
    );
  }
}