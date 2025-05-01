import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/product_service.dart';
import 'services/loyalty_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => LoyaltyService()),
      ],
      child: MaterialApp(
        title: 'Padaria App',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.orangeAccent),
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.brown),
            displayMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.brown[700]),
            bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.brown,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
