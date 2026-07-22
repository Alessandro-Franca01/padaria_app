import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/product_service.dart';
import 'services/category_service.dart';
import 'services/discount_service.dart';
import 'services/loyalty_service.dart';
import 'services/order_service.dart';
import 'services/chat_service.dart';
import 'services/subscription_service.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  MyApp({super.key}) {
    // Sessão expirada/token inválido em qualquer chamada autenticada:
    // limpa o estado local e manda o usuário de volta para o login.
    ApiClient.onUnauthorized = () {
      _authService.clearSession();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => CategoryService()),
        ChangeNotifierProvider(create: (_) => DiscountService()),
        ChangeNotifierProvider(create: (_) => LoyaltyService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        routes: {
          '/login': (context) => LoginScreen(),
        },
        title: 'Padaria App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: SplashScreen(), // Set SplashScreen as the initial route
      ),
    );
  }
}
