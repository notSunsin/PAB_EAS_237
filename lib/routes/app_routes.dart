import 'package:flutter/material.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/product/product_detail_screen.dart';
import '../presentation/screens/cart/cart_screen.dart';
import '../presentation/screens/checkout/checkout_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

class AppRoutes {
  static const splash        = '/';
  static const login         = '/login';
  static const register      = '/register';
  static const home          = '/home';
  static const productDetail = '/product-detail';
  static const cart          = '/cart';
  static const checkout      = '/checkout';
  static const profile       = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _build(const SplashScreen());
      case login:
        return _build(const LoginScreen());
      case register:
        return _build(const RegisterScreen());
      case home:
        return _build(const HomeScreen());
      case productDetail:
        final id = settings.arguments as int;
        return _build(ProductDetailScreen(productId: id));
      case cart:
        return _build(const CartScreen());
      case checkout:
        return _build(const CheckoutScreen());
      case profile:
        return _build(const ProfileScreen());
      default:
        return _build(const SplashScreen());
    }
  }

  static MaterialPageRoute _build(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}
