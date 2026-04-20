import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  const ProductService();

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
}
