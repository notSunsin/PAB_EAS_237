import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo;
  ProductProvider({ProductRepository? repo})
      : _repo = repo ?? ProductRepository();

  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = ['semua'];
  String _selectedCategory = 'semua';
  String _searchQuery = '';
  String? _errorMessage;
  ProductModel? _selectedProduct;
  ProductStatus _detailStatus = ProductStatus.initial;

  ProductStatus get status => _status;
  ProductStatus get detailStatus => _detailStatus;
  List<ProductModel> get products => _filteredProducts;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  ProductModel? get selectedProduct => _selectedProduct;

  // ── Muat semua produk dan kategori ────────────────────────────────────────
  Future<void> loadProducts() async {
    _status = ProductStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.getProducts(),
        _repo.getCategories(),
      ]);
      _allProducts = results[0] as List<ProductModel>;
      _categories = ['semua', ...(results[1] as List<String>)];
      _applyFilter();
      _status = ProductStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProductStatus.error;
    }
    notifyListeners();
  }

  // ── Detail produk ─────────────────────────────────────────────────────────
  Future<void> loadProductDetail(int id) async {
    _detailStatus = ProductStatus.loading;
    _selectedProduct = null;
    notifyListeners();
    try {
      _selectedProduct = await _repo.getProductById(id);
      _detailStatus = ProductStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _detailStatus = ProductStatus.error;
    }
    notifyListeners();
  }

  // ── Filter kategori ───────────────────────────────────────────────────────
  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  // ── Pencarian ─────────────────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // ── Muat ulang ────────────────────────────────────────────────────────────
  Future<void> refresh() => loadProducts();

  void _applyFilter() {
    List<ProductModel> result = _allProducts;
    if (_selectedCategory != 'semua') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q))
          .toList();
    }
    _filteredProducts = result;
  }

  // ── Delete produk (demo) ──────────────────────────────────────────────────
  Future<void> deleteProduct(int id) async {
    try {
      await _repo.deleteProduct(id);
      _allProducts.removeWhere((p) => p.id == id);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
