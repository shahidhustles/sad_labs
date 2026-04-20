import 'package:flutter/material.dart';

import 'models/product.dart';
import 'services/product_service.dart';

enum _ProductAction { edit, delete }

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _productService = const ProductService();
  final List<Product> _products = [];
  late Future<void> _productsFuture;
  bool _isAddingProduct = false;
  int? _busyProductId;
  _ProductAction? _busyAction;

  bool get _isBusy => _isAddingProduct || _busyProductId != null;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _productService.fetchProducts();
    _products
      ..clear()
      ..addAll(products);
  }

  Future<void> _showAddDialog() async {
    if (_isBusy) return;

    final draft = await showDialog<ProductDraft>(
      context: context,
      builder: (dialogContext) => const _ProductFormDialog(
        title: 'Add Product',
        submitLabel: 'Add',
      ),
    );

    if (draft == null || !mounted) return;

    setState(() {
      _isAddingProduct = true;
    });

    try {
      final createdProduct = await _productService.addProduct(draft);
      final nextId = _resolveCreatedProductId(createdProduct.id);
      final productToDisplay = Product.fromDraft(
        id: nextId,
        draft: draft,
        ratingRate: createdProduct.ratingRate,
        ratingCount: createdProduct.ratingCount,
      );

      setState(() {
        _products.add(productToDisplay);
      });

      _showSnackBar(
        message: 'Product added successfully',
        backgroundColor: Colors.green,
      );
    } catch (error) {
      _showSnackBar(
        message: 'Unable to add product: $error',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingProduct = false;
        });
      }
    }
  }

  Future<void> _showEditDialog(Product product) async {
    if (_isBusy) return;

    final draft = await showDialog<ProductDraft>(
      context: context,
      builder: (dialogContext) => _ProductFormDialog(
        title: 'Edit Product',
        submitLabel: 'Update',
        initialDraft: ProductDraft.fromProduct(product),
      ),
    );

    if (draft == null || !mounted) return;

    setState(() {
      _busyProductId = product.id;
      _busyAction = _ProductAction.edit;
    });

    try {
      await _productService.updateProduct(product.id, draft);

      final updatedProduct = product.copyWith(
        title: draft.title,
        price: draft.price,
        description: draft.description,
        category: draft.category,
        image: draft.image,
      );

      setState(() {
        final index = _products.indexWhere((item) => item.id == product.id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
      });

      _showSnackBar(
        message: 'Product updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (error) {
      _showSnackBar(
        message: 'Unable to update product: $error',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyProductId = null;
          _busyAction = null;
        });
      }
    }
  }

  Future<void> _confirmDelete(Product product) async {
    if (_isBusy) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Delete "${product.title}" from the list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() {
      _busyProductId = product.id;
      _busyAction = _ProductAction.delete;
    });

    try {
      await _productService.deleteProduct(product.id);

      setState(() {
        _products.removeWhere((item) => item.id == product.id);
      });

      _showSnackBar(
        message: 'Product deleted successfully',
        backgroundColor: Colors.green,
      );
    } catch (error) {
      _showSnackBar(
        message: 'Unable to delete product: $error',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyProductId = null;
          _busyAction = null;
        });
      }
    }
  }

  int _resolveCreatedProductId(int apiId) {
    if (apiId > 0 && _products.every((product) => product.id != apiId)) {
      return apiId;
    }

    var nextId = 1;
    for (final product in _products) {
      if (product.id >= nextId) {
        nextId = product.id + 1;
      }
    }
    return nextId;
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isBusy ? null : _showAddDialog,
        icon: _isAddingProduct
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(_isAddingProduct ? 'Adding...' : 'Add Product'),
      ),
      body: FutureBuilder<void>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load products.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (_products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              final isBusyProduct = _busyProductId == product.id;

              return _ProductCard(
                product: product,
                actionsEnabled: !_isBusy,
                busyAction: isBusyProduct ? _busyAction : null,
                onEdit: () => _showEditDialog(product),
                onDelete: () => _confirmDelete(product),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.actionsEnabled,
    required this.busyAction,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final bool actionsEnabled;
  final _ProductAction? busyAction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 48);
                      },
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(5, (index) {
                              final filled = index < product.ratingRate.round();
                              return Icon(
                                filled ? Icons.star : Icons.star_border,
                                size: 16,
                                color: Colors.amber,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              '${product.ratingRate.toStringAsFixed(1)} (${product.ratingCount})',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        product.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: actionsEnabled ? onEdit : null,
                            icon: busyAction == _ProductAction.edit
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.edit),
                            label: Text(
                              busyAction == _ProductAction.edit
                                  ? 'Updating...'
                                  : 'Edit',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: actionsEnabled ? onDelete : null,
                            icon: busyAction == _ProductAction.delete
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.delete),
                            label: Text(
                              busyAction == _ProductAction.delete
                                  ? 'Deleting...'
                                  : 'Delete',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({
    required this.title,
    required this.submitLabel,
    this.initialDraft,
  });

  final String title;
  final String submitLabel;
  final ProductDraft? initialDraft;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    final initialDraft = widget.initialDraft;
    _titleController = TextEditingController(text: initialDraft?.title ?? '');
    _priceController = TextEditingController(
      text: initialDraft?.price.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: initialDraft?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: initialDraft?.category ?? '',
    );
    _imageController = TextEditingController(text: initialDraft?.image ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      ProductDraft(
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        image: _imageController.text.trim(),
      ),
    );
  }

  String? _validateRequiredText(String? value, String label) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return 'Please enter $label';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return 'Please enter price';
    }

    final parsedValue = double.tryParse(trimmedValue);
    if (parsedValue == null) {
      return 'Please enter a valid price';
    }

    if (parsedValue <= 0) {
      return 'Price must be greater than 0';
    }

    return null;
  }

  String? _validateImageUrl(String? value) {
    final requiredError = _validateRequiredText(value, 'image URL');
    if (requiredError != null) return requiredError;

    final uri = Uri.tryParse(value!.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'Please enter a valid image URL';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => _validateRequiredText(value, 'title'),
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validatePrice,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => _validateRequiredText(value, 'category'),
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: _validateImageUrl,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => _validateRequiredText(value, 'description'),
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
