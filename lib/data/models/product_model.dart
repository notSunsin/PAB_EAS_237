class RatingModel {
  final double rate;
  final int count;

  const RatingModel({required this.rate, required this.count});

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
        count: (json['count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {'rate': rate, 'count': count};
}

class ProductModel {
  final int id;
  final String title;
  final double price; // USD dari FakeStore, dikonversi ke IDR saat tampil
  final String description;
  final String category;
  final String image;
  final RatingModel rating;
  int stock;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    this.stock = 50,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] ?? '',
        category: json['category'] ?? '',
        image: json['image'] ?? '',
        rating: json['rating'] != null
            ? RatingModel.fromJson(json['rating'])
            : const RatingModel(rate: 0, count: 0),
        stock: (json['stock'] as num?)?.toInt() ?? 50,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': image,
        'rating': rating.toJson(),
        'stock': stock,
      };

  // Harga untuk POST/PUT ke API
  static Map<String, dynamic> toCreateJson({
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
  }) =>
      {
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': image,
      };
}
