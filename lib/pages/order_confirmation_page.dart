// lib/pages/order_confirmation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard/dashboard_page.dart'; // Import CartItem
import 'package:flutter_application_1/model/address_data.dart'; // Import AddressData
import 'package:get/get.dart'; // Pastikan GetX diimpor

class OrderConfirmationPage extends StatelessWidget {
  final List<CartItem> confirmedOrderItems;
  final AddressData? deliveryAddress;
  final String paymentMethod;
  final double totalAmount;

  const OrderConfirmationPage({
    super.key,
    required this.confirmedOrderItems,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        leading: IconButton( // Tombol kembali di AppBar
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Mengarahkan ke Dashboard dan membersihkan semua rute sebelumnya
            Get.offAllNamed('/dashboard'); // <--- Solusi utama di sini
          },
        ),
        // Jika Anda sebelumnya memiliki automaticallyImplyLeading: false, pastikan itu dihapus
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pesanan Berhasil Ditempatkan!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Terima kasih atas pesanan Anda. Detail pesanan Anda ada di bawah.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'Ringkasan Pesanan Anda',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: confirmedOrderItems.length,
                  itemBuilder: (context, index) {
                    final item = confirmedOrderItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              item.product.thumbnail,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Rp ${item.product.price.toStringAsFixed(0)} x ${item.quantity}',
                                  style: const TextStyle(color: Colors.grey),
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
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Detail Pengiriman & Pembayaran',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat Pengiriman:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(deliveryAddress?.title ?? 'Tidak ada alamat', style: const TextStyle(fontSize: 15)),
                    Text(deliveryAddress?.snippet ?? '', style: const TextStyle(color: Colors.grey)),
                    if (deliveryAddress?.latLng != null)
                      Text(
                        'Koordinat: ${deliveryAddress!.latLng!.latitude.toStringAsFixed(4)}, ${deliveryAddress!.latLng!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      'Metode Pembayaran:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(paymentMethod, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Rp ${totalAmount.toStringAsFixed(0)}',
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
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Mengarahkan ke Dashboard dan membersihkan semua rute sebelumnya
                  Get.offAllNamed('/dashboard'); // <--- Solusi utama di sini
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
