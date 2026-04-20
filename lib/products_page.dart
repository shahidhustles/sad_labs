import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(
        child: Text(
          'Products page ready.\nFetching and cards will be added next.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
