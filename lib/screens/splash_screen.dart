import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Atraso para exibir a tela de splash por pelo menos 2 segundos
    await Future.delayed(Duration(seconds: 2));
    
    // Tenta fazer login automático com dados salvos
    final authService = Provider.of<AuthService>(context, listen: false);
    final productService = Provider.of<ProductService>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);
    
    // Carrega os produtos
    await productService.refreshProducts();
    
    // Tenta fazer login automático
    final isLoggedIn = await authService.tryAutoLogin();
    
    // Se o usuário estiver logado, carrega os dados do carrinho
    if (isLoggedIn) {
      await cartService.loadCartFromStorage(productService);
    }
    
    // Navega para a tela inicial ou de login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => isLoggedIn ? HomeScreen() : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown[800]!,
              Colors.brown[600]!,
              Colors.brown[400]!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.bakery_dining,
                size: 80,
                color: Colors.brown[700],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Padaria App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Seu pão fresquinho na palma da mão',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
