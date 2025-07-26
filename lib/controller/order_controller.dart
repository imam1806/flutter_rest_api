// lib/controller/order_controller.dart
import 'package:get/get.dart';
import 'package:flutter_application_1/pages/dashboard/dashboard_page.dart'; // Untuk CartItem

class OrderController extends GetxController {
  // Gunakan RxList agar reaktif dan dapat dipantau oleh Obx
  final RxList<List<CartItem>> _orderHistory = <List<CartItem>>[].obs;

  // Getter untuk mengekspos riwayat pesanan
  List<List<CartItem>> get orderHistory => _orderHistory.value;

  // Metode untuk menambahkan pesanan baru
  void addOrder(List<CartItem> confirmedItems) {
    if (confirmedItems.isNotEmpty) {
      _orderHistory.insert(0, confirmedItems); // Tambahkan pesanan baru ke awal daftar
      // Anda bisa menambahkan logika penyimpanan ke SharedPreferences di sini jika ingin persisten
      print('OrderController: Pesanan baru ditambahkan. Total pesanan: ${_orderHistory.length}');
    }
  }
}
