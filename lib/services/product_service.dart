import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  const ProductService();

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  Future<List<Product>> fetchProducts() async {
    final url = Uri.https('fakestoreapi.com', '/products');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load products. Status code: ${response.statusCode}',
      );
    }

    return productFromMap(response.body);
  }

  Future<Product> addProduct(ProductDraft draft) async {
    final url = Uri.https('fakestoreapi.com', '/products');
    final response = await http.post(
      url,
      headers: _jsonHeaders,
      body: jsonEncode(draft.toMap()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to add product. Status code: ${response.statusCode}',
      );
    }

    return singleProductFromMap(response.body);
  }

  Future<Product> updateProduct(int id, ProductDraft draft) async {
    final url = Uri.https('fakestoreapi.com', '/products/$id');
    final response = await http.put(
      url,
      headers: _jsonHeaders,
      body: jsonEncode(draft.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update product. Status code: ${response.statusCode}',
      );
    }

    return singleProductFromMap(response.body);
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.https('fakestoreapi.com', '/products/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete product. Status code: ${response.statusCode}',
      );
    }
  }
}
