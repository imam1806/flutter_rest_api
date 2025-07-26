// lib/controller/product_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart'; // Untuk Colors dan SnackBar di Get.snackbar
import 'package:flutter_application_1/model/product_model.dart'; // Sesuaikan jalur impor
import 'package:get/get.dart';
import 'package:http/http.dart'
    as http; // Gunakan paket http untuk panggilan API

class ProductController extends GetxController {
  final String url = 'https://dummyjson.com';

  var isLoading = false.obs; // Observable untuk status loading
  RxList<Product> products =
      <Product>[].obs; // Daftar produk yang dapat diamati
  Rx<Product?> product = Rx<Product?>(
    null,
  ); // Produk tunggal yang dapat diamati

  @override
  void onInit() {
    super.onInit();
    getProducts(); // Ambil produk saat controller diinisialisasi
  }

  Future<void> getProducts() async {
    isLoading(true); // Atur loading ke true
    try {
      final response = await http.get(
        Uri.parse('$url/products?skip=0&limit=10'),
      ); // Ambil 10 produk
      if (response.statusCode == 200) {
        // Periksa apakah berhasil
        final data = jsonDecode(response.body); // Dekode respons JSON
        products.value = List<Product>.from(
          data['products'].map((x) => Product.fromMap(x)),
        ); // Petakan ke objek Product
      } else {
        Get.snackbar(
          'Error',
          'Gagal memuat produk: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal terhubung ke API: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false); // Atur loading ke false
    }
  }

  Future<void> findProduct(int id) async {
    isLoading(true); // Atur loading ke true
    try {
      final response = await http.get(
        Uri.parse('$url/products/$id'),
      ); // Ambil produk tunggal berdasarkan ID
      if (response.statusCode == 200) {
        // Periksa apakah berhasil
        final data = jsonDecode(response.body); // Dekode respons JSON
        product.value = Product.fromMap(data); // Petakan ke objek Product
      } else {
        Get.snackbar(
          'Error',
          'Gagal menemukan produk: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        product.value = null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal terhubung ke API: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      product.value = null;
    } finally {
      isLoading(false); // Atur loading ke false
    }
  }

  Future<Product?> addProduct(Product newProduct) async {
    isLoading(true); // Atur loading ke true
    log(newProduct.toMap().toString()); // Log data produk baru
    try {
      final response = await http.post(
        // Permintaan POST untuk menambahkan produk
        Uri.parse('$url/products/add'),
        body: newProduct.toMap(),
      );

      log(response.body.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 201 Created umum untuk POST
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Sukses',
          'Produk ditambahkan: ${data['title']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        getProducts(); // Segarkan daftar setelah menambahkan
        return Product.fromMap(data);
      } else {
        Get.snackbar(
          'Error',
          'Gagal menambahkan produk: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal terhubung ke API: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading(false); // Atur loading ke false
    }
  }

  Future<Product?> updateProduct(Product updatedProduct) async {
    isLoading(true); // Atur loading ke true
    try {
      final response = await http.put(
        // Permintaan PUT untuk memperbarui produk
        Uri.parse('$url/products/${updatedProduct.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedProduct.toMap()),
      );
      if (response.statusCode == 200) {
        // Periksa apakah berhasil
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Sukses',
          'Produk diperbarui: ${data['title']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        getProducts(); // Segarkan daftar setelah memperbarui
        return Product.fromMap(data);
      } else {
        Get.snackbar(
          'Error',
          'Gagal memperbarui produk: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal terhubung ke API: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading(false); // Atur loading ke false
    }
  }

  Future<Product?> deleteProduct(int id) async {
    isLoading(true); // Atur loading ke true
    try {
      final response = await http.delete(
        Uri.parse('$url/products/$id'),
      ); // Permintaan DELETE
      if (response.statusCode == 200) {
        // Periksa apakah berhasil
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Sukses',
          'Produk dihapus!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        getProducts(); // Segarkan daftar setelah menghapus
        return Product.fromMap(
          data,
        ); // Mengembalikan detail produk yang dihapus
      } else {
        Get.snackbar(
          'Error',
          'Gagal menghapus produk: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal terhubung ke API: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading(false); // Atur loading ke false
    }
  }
}
