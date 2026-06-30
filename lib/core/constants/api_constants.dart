class ApiConstants {
  // Ganti baseUrl dengan endpoint API custom kamu
  static const String baseUrl = 'https://fakestoreapi.com';

  static const String products    = '/products';
  static const String categories  = '/products/categories';
  static const String authLogin   = '/auth/login';
  static const String users       = '/users';

  static String productById(int id)          => '/products/$id';
  static String productsByCategory(String c) => '/products/category/$c';

  static const Duration timeout = Duration(seconds: 15);
}
