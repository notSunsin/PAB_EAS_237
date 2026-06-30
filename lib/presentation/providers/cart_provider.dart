import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;
  int get itemCount => _items.fold(0, (sum, e) => sum + e.quantity);
  bool get isEmpty => _items.isEmpty;

  double get subtotalIDR =>
      _items.fold(0.0, (sum, e) => sum + e.subtotalIDR);

  double get taxIDR => subtotalIDR * AppConstants.taxRate;
  double get totalIDR => subtotalIDR + taxIDR;

  // ── Muat cart dari lokal ──────────────────────────────────────────────────
  Future<void> loadCart() async {
    final json = LocalStorageService.getCartJson();
    if (json != null && json.isNotEmpty) {
      try {
        _items = CartItemModel.listFromJsonString(json);
      } catch (_) {
        _items = [];
      }
    }
    notifyListeners();
  }

  // ── Tambah ke cart ────────────────────────────────────────────────────────
  void addToCart(ProductModel product, {int qty = 1}) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity += qty;
    } else {
      _items.add(CartItemModel(product: product, quantity: qty));
    }
    _save();
    notifyListeners();
  }

  // ── Increment ─────────────────────────────────────────────────────────────
  void increment(int productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      _items[idx].increment();
      _save();
      notifyListeners();
    }
  }

  // ── Decrement ─────────────────────────────────────────────────────────────
  void decrement(int productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (_items[idx].quantity <= 1) {
        _items.removeAt(idx);
      } else {
        _items[idx].decrement();
      }
      _save();
      notifyListeners();
    }
  }

  // ── Hapus item ────────────────────────────────────────────────────────────
  void removeItem(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _save();
    notifyListeners();
  }

  // ── Kosongkan cart ────────────────────────────────────────────────────────
  Future<void> clearCart() async {
    _items = [];
    await LocalStorageService.clearCart();
    notifyListeners();
  }

  // ── Cek apakah produk ada di cart ────────────────────────────────────────
  bool isInCart(int productId) =>
      _items.any((i) => i.product.id == productId);

  int quantityOf(int productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }

  Future<void> _save() async {
    await LocalStorageService.saveCart(
        CartItemModel.listToJsonString(_items));
  }
}
