import 'dart:convert';

List<Product> productFromMap(String source) {
  final decoded = json.decode(source) as List<dynamic>;
  return decoded
      .map((productMap) => Product.fromMap(productMap as Map<String, dynamic>))
      .toList();
}

Product singleProductFromMap(String source) {
  final decoded = json.decode(source) as Map<String, dynamic>;
  return Product.fromMap(decoded);
}

class ProductDraft {
  const ProductDraft({
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  factory ProductDraft.fromProduct(Product product) {
    return ProductDraft(
      title: product.title,
      price: product.price,
      description: product.description,
      category: product.category,
      image: product.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
    };
  }
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

  factory Product.fromDraft({
    required int id,
    required ProductDraft draft,
    double ratingRate = 0,
    int ratingCount = 0,
  }) {
    return Product(
      id: id,
      title: draft.title,
      price: draft.price,
      description: draft.description,
      category: draft.category,
      image: draft.image,
      ratingRate: ratingRate,
      ratingCount: ratingCount,
    );
  }

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    double? ratingRate,
    int? ratingCount,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      ratingRate: ratingRate ?? this.ratingRate,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
