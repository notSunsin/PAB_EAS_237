import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) throw Exception('LocalStorageService belum diinisialisasi');
    return _prefs!;
  }

  // ── Token ──────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) =>
      _instance.setString(AppConstants.tokenKey, token);

  static String? getToken() => _instance.getString(AppConstants.tokenKey);

  static Future<void> removeToken() =>
      _instance.remove(AppConstants.tokenKey);

  // ── User ───────────────────────────────────────────────────────────────────
  static Future<void> saveUser(String userJson) =>
      _instance.setString(AppConstants.userKey, userJson);

  static String? getUserJson() => _instance.getString(AppConstants.userKey);

  static Future<void> removeUser() =>
      _instance.remove(AppConstants.userKey);

  // ── Registered users (simulasi auth lokal) ────────────────────────────────
  static Future<void> saveRegisteredUsers(String usersJson) =>
      _instance.setString(AppConstants.registeredKey, usersJson);

  static String? getRegisteredUsers() =>
      _instance.getString(AppConstants.registeredKey);

  // ── Cart ───────────────────────────────────────────────────────────────────
  static Future<void> saveCart(String cartJson) =>
      _instance.setString(AppConstants.cartKey, cartJson);

  static String? getCartJson() => _instance.getString(AppConstants.cartKey);

  static Future<void> clearCart() =>
      _instance.remove(AppConstants.cartKey);

  // ── Addresses ─────────────────────────────────────────────────────────────
  static Future<void> saveAddresses(String addressesJson) =>
      _instance.setString('saved_addresses', addressesJson);

  static String? getAddressesJson() => _instance.getString('saved_addresses');

  // ── Orders ───────────────────────────────────────────────────────────────
  static Future<void> saveOrders(String ordersJson) =>
      _instance.setString('order_history', ordersJson);

  static String? getOrdersJson() => _instance.getString('order_history');

  // ── Profile image ──────────────────────────────────────────────────────────
  static Future<void> saveProfileImagePath(String path) =>
      _instance.setString(AppConstants.profileImgKey, path);

  static String? getProfileImagePath() =>
      _instance.getString(AppConstants.profileImgKey);

  // ── Clear all (logout) ─────────────────────────────────────────────────────
  static Future<void> clearSession() async {
    await removeToken();
    await removeUser();
    await _instance.remove(AppConstants.cartKey);
    await _instance.remove(AppConstants.profileImgKey);
  }
}
