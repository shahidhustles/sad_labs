import 'dart:convert';

List<Product> productFromMap(String source) {
  final decoded = json.decode(source) as List<dynamic>;
  return decoded
      .map((productMap) => Product.fromMap(productMap as Map<String, dynamic>))
      .toList();
}

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.ratingRate,
    required this.ratingCount,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double ratingRate;
  final int ratingCount;

  factory Product.fromMap(Map<String, dynamic> map) {
    final rating = map['rating'] as Map<String, dynamic>? ?? {};
    return Product(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      image: map['image'] as String? ?? '',
      ratingRate: (rating['rate'] as num?)?.toDouble() ?? 0,
      ratingCount: rating['count'] as int? ?? 0,
    );
  }
}
