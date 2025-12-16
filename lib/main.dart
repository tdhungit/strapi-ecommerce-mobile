import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:strapi_ecommerce_flutter/screens/category_screen.dart';
import 'package:strapi_ecommerce_flutter/screens/checkout_screen.dart';
import 'package:strapi_ecommerce_flutter/screens/product_detail_screen.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  await dotenv.load(fileName: ".env", overrideWithFiles: [".env.local"]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strapi E-commerce',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            AuthService.isLoggedIn() ? const HomeScreen() : const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
      onGenerateRoute: (settings) {
        // Product category
        if (settings.name != null && settings.name!.startsWith('/category/')) {
          final uri = Uri.parse(settings.name!);
          if (uri.pathSegments.length == 2 &&
              uri.pathSegments[0] == 'category') {
            final id = uri.pathSegments[1];
            return MaterialPageRoute(
              builder: (context) => CategoryScreen(categoryId: id),
            );
          }
        }
        // Product detail
        if (settings.name != null && settings.name!.startsWith('/product/')) {
          final uri = Uri.parse(settings.name!);
          if (uri.pathSegments.length == 2 &&
              uri.pathSegments[0] == 'product') {
            final id = uri.pathSegments[1];
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: id),
            );
          }
        }
        return null;
      },
    );
  }
}
