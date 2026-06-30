class AppConstants {
  static const String appName       = 'Pasar Lokal';
  static const String appTagline    = 'Belanja UMKM Terpercaya';

  // SharedPreferences keys
  static const String tokenKey      = 'auth_token';
  static const String userKey       = 'user_data';
  static const String cartKey       = 'cart_items';
  static const String registeredKey = 'registered_users';
  static const String profileImgKey = 'profile_image_path';

  // Konversi harga USD → IDR (demo)
  static const double priceMultiplier = 15000;

  // PPN
  static const double taxRate = 0.11;
}
