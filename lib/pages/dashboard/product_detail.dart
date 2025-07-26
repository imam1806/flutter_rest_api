// lib/pages/product_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controller/product_controller.dart'; // Ensure this path is correct
import 'package:flutter_application_1/model/product_model.dart'; // Ensure this path is correct
import 'package:get/get.dart';

class ProductDetail extends StatelessWidget {
  final Product?
  initialProduct; // Optional product to pre-fill the form if editing
  final ProductController controller =
      Get.find(); // Get an instance of ProductController

  ProductDetail({this.initialProduct, super.key});

  // Helper method for consistent TextField decoration
  InputDecoration _inputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // Slightly rounded corners
      ),
      filled: true,
      fillColor: Colors.grey[50], // Light background for input fields
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize text controllers with initialProduct data if available
    final titleController = TextEditingController(text: initialProduct?.title);
    final descriptionController = TextEditingController(
      text: initialProduct?.description,
    );
    final priceController = TextEditingController(
      text: initialProduct?.price.toStringAsFixed(0) ?? '0',
    );
    final discountController = TextEditingController(
      text: initialProduct?.discountPercentage.toStringAsFixed(2) ?? '0.0',
    );
    final stockController = TextEditingController(
      text: initialProduct?.stock.toString() ?? '1',
    );
    final brandController = TextEditingController(text: initialProduct?.brand);
    final categoryController = TextEditingController(
      text: initialProduct?.category,
    );
    final thumbnailController = TextEditingController(
      text: initialProduct?.thumbnail,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (initialProduct?.thumbnail != null &&
                initialProduct!.thumbnail.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      15,
                    ), // Slightly more rounded corners
                    child: Image.network(
                      initialProduct!.thumbnail,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.broken_image,
                              size: 80, // Larger icon for broken image
                              color: Colors.grey[600],
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            Text('Title', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: _inputDecoration(
                'Title',
                hintText: 'Masukkan judul produk',
              ),
            ),
            const SizedBox(height: 16), // Increased spacing

            Text('Description', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3, // Allow multiple lines for description
              decoration: _inputDecoration(
                'Description',
                hintText: 'Masukkan deskripsi produk',
              ),
            ),
            const SizedBox(height: 16),

            Text('Price', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Price',
                hintText: 'Masukkan harga produk',
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Discount Percentage',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: discountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ), // Allow decimals
              decoration: _inputDecoration(
                'Discount',
                hintText: 'Masukkan persentase diskon',
              ),
            ),
            const SizedBox(height: 16),

            Text('Stock', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Stock',
                hintText: 'Masukkan jumlah stok',
              ),
            ),
            const SizedBox(height: 16),

            Text('Brand', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: brandController,
              decoration: _inputDecoration(
                'Brand',
                hintText: 'Masukkan merek produk',
              ),
            ),
            const SizedBox(height: 16),

            Text('Category', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: categoryController,
              decoration: _inputDecoration(
                'Category',
                hintText: 'Masukkan kategori produk',
              ),
            ),
            const SizedBox(height: 16),

            Text('Thumbnail URL', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: thumbnailController,
              keyboardType: TextInputType.url,
              decoration: _inputDecoration(
                'Thumbnail URL',
                hintText: 'Masukkan URL gambar thumbnail',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
