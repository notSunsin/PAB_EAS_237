import '../models/product_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class ProductRepository {
  final ApiService _api;
  ProductRepository({ApiService? api}) : _api = api ?? ApiService();

  // ── GET ALL ────────────────────────────────────────────────────────────────
  Future<List<ProductModel>> getProducts({int? limit}) async {
    final endpoint = limit != null
        ? '${ApiConstants.products}?limit=$limit'
        : ApiConstants.products;
    final data = await _api.get(endpoint) as List;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<ProductModel> getProductById(int id) async {
    final data = await _api.get(ApiConstants.productById(id));
    return ProductModel.fromJson(data);
  }

  // ── GET CATEGORIES ─────────────────────────────────────────────────────────
  Future<List<String>> getCategories() async {
    final data = await _api.get(ApiConstants.categories) as List;
    return data.map((e) => e.toString()).toList();
  }

  // ── GET BY CATEGORY ────────────────────────────────────────────────────────
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final data = await _api.get(ApiConstants.productsByCategory(category)) as List;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  // ── POST (create) ──────────────────────────────────────────────────────────
  Future<ProductModel> createProduct({
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
  }) async {
    final body = ProductModel.toCreateJson(
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
    );
    final data = await _api.post(ApiConstants.products, body);
    return ProductModel.fromJson(data);
  }

  // ── PUT (update) ───────────────────────────────────────────────────────────
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> body) async {
    final data = await _api.put(ApiConstants.productById(id), body);
    return ProductModel.fromJson(data);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<void> deleteProduct(int id) async {
    await _api.delete(ApiConstants.productById(id));
  }
}
