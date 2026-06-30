import 'dart:convert';
import 'product_model.dart';
import '../../core/constants/app_constants.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get subtotalIDR =>
      product.price * AppConstants.priceMultiplier * quantity;

  void increment() => quantity++;
  void decrement() {
    if (quantity > 1) quantity--;
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        product: ProductModel.fromJson(json['product']),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );

  static List<CartItemModel> listFromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return list.map((e) => CartItemModel.fromJson(e)).toList();
  }

  static String listToJsonString(List<CartItemModel> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}
