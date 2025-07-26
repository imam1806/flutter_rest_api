// lib/pages/order_history_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Impor GetX
import 'package:flutter_application_1/controller/order_controller.dart'; // <--- Impor OrderController

class OrderHistoryPage extends StatelessWidget {
  // Hapus final List<List<CartItem>> orderHistory;
  // Karena sekarang akan diambil dari controller
  final OrderController orderController = Get.find();

  OrderHistoryPage({
    super.key,
  }); // Hapus parameter orderHistory dari konstruktor

  @override
  Widget build(BuildContext context) {
    // Dapatkan instance OrderController

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Obx(
        // <--- Gunakan Obx untuk mengamati perubahan pada orderHistory
        () {
          if (orderController.orderHistory.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum memiliki pesanan.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount:
                  orderController
                      .orderHistory
                      .length, // <--- Ambil dari controller
              itemBuilder: (context, orderIndex) {
                final order =
                    orderController
                        .orderHistory[orderIndex]; // <--- Ambil dari controller
                double orderTotal = order.fold(
                  0.0,
                  (sum, item) => sum + item.totalPrice,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesanan #${orderController.orderHistory.length - orderIndex}', // Nomor pesanan dari yang terbaru
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.length,
                          itemBuilder: (context, itemIndex) {
                            final item = order[itemIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      item.product.thumbnail,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 25,
                                                color: Colors.grey,
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Rp ${item.product.price.toStringAsFixed(0)} x ${item.quantity}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${item.totalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(height: 20, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pesanan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Rp ${orderTotal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
