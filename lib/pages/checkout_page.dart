// lib/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboard/dashboard_page.dart'; // Import CartItem
import 'package:flutter_application_1/pages/address_map_page.dart'; // Import AddressMapPage
import 'package:flutter_application_1/model/address_data.dart'; // Import model AddressData
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan/memuat alamat
import 'package:flutter_application_1/pages/order_confirmation_page.dart'; // Import halaman konfirmasi pesanan

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(List<CartItem>) onCheckoutSuccess; // <--- Tipe callback diubah

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.onCheckoutSuccess,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = 'Cash on Delivery (COD)';
  AddressData? _deliveryAddress; // Variabel untuk menyimpan alamat pengiriman

  @override
  void initState() {
    super.initState();
    _loadDeliveryAddress(); // Muat alamat pengiriman saat inisialisasi
  }

  Future<void> _loadDeliveryAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString('deliveryAddressTitle');
    final snippet = prefs.getString('deliveryAddressSnippet');
    final lat = prefs.getDouble('deliveryAddressLat');
    final lng = prefs.getDouble('deliveryAddressLng');

    if (title != null && snippet != null) {
      setState(() {
        _deliveryAddress = AddressData(
          title: title,
          snippet: snippet,
          latLng: (lat != null && lng != null) ? LatLng(lat, lng) : null,
        );
      });
    } else {
      // Set alamat default jika belum ada yang tersimpan
      setState(() {
        _deliveryAddress = AddressData(
          title: 'Alamat Rumah Default',
          snippet: 'Jl. Contoh No. 123, Bekasi',
          latLng: const LatLng(-6.340583, 107.042056), // Koordinat rumah default
        );
      });
    }
  }

  Future<void> _saveDeliveryAddress(AddressData address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deliveryAddressTitle', address.title);
    await prefs.setString('deliveryAddressSnippet', address.snippet);
    if (address.latLng != null) {
      await prefs.setDouble('deliveryAddressLat', address.latLng!.latitude);
      await prefs.setDouble('deliveryAddressLng', address.latLng!.longitude);
    } else {
      await prefs.remove('deliveryAddressLat');
      await prefs.remove('deliveryAddressLng');
    }
  }

  void _placeOrder() {
    if (_deliveryAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih alamat pengiriman terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Simpan item keranjang saat ini sebelum dikosongkan
    final List<CartItem> itemsToConfirm = List.from(widget.cartItems);
    final double finalTotalAmount = widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice) + 15000.0; // Tambah biaya pengiriman

    widget.onCheckoutSuccess(itemsToConfirm); // <--- Meneruskan item yang dikonfirmasi

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesanan Anda sedang diproses!'),
        backgroundColor: Colors.blue,
      ),
    );

    // Navigasi ke halaman konfirmasi pesanan
    Navigator.pushReplacement( // Menggunakan pushReplacement agar tidak bisa kembali ke halaman checkout
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          confirmedOrderItems: itemsToConfirm,
          deliveryAddress: _deliveryAddress,
          paymentMethod: _selectedPaymentMethod,
          totalAmount: finalTotalAmount,
        ),
      ),
    );
  }

  Future<void> _navigateToAddressMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressMapPage()),
    );

    if (result != null && result is AddressData) {
      setState(() {
        _deliveryAddress = result;
      });
      _saveDeliveryAddress(result); // Simpan alamat yang dipilih
    }
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = widget.cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    double shippingCost = 15000.0;
    double totalAmount = subtotal + shippingCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Pesanan
            Text(
              'Ringkasan Pesanan',
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
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
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

            // Detail Harga
            Text(
              'Detail Harga',
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Produk'),
                        Text('Rp ${subtotal.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Pengiriman'),
                        Text('Rp ${shippingCost.toStringAsFixed(0)}'),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
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
            const SizedBox(height: 20),

            // Alamat Pengiriman
            Text(
              'Alamat Pengiriman',
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
                      _deliveryAddress?.title ?? 'Belum ada alamat dipilih',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _deliveryAddress?.snippet ?? 'Ketuk "Ubah Alamat" untuk memilih.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    _deliveryAddress?.latLng != null
                        ? Text(
                            'Koordinat: ${_deliveryAddress!.latLng!.latitude.toStringAsFixed(4)}, ${_deliveryAddress!.latLng!.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          )
                        : const SizedBox.shrink(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton.icon(
                        onPressed: _navigateToAddressMap, // Panggil fungsi navigasi
                        icon: const Icon(Icons.edit, size: 18, color: Colors.lightBlueAccent),
                        label: const Text('Ubah Alamat', style: TextStyle(color: Colors.lightBlueAccent)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metode Pembayaran
            Text(
              'Metode Pembayaran',
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
                  children: [
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery (COD)'),
                      value: 'Cash on Delivery (COD)',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      activeColor: Colors.lightBlueAccent,
                    ),
                    RadioListTile<String>(
                      title: const Text('Transfer Bank'),
                      value: 'Transfer Bank',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      activeColor: Colors.lightBlueAccent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Place Order
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.cartItems.isEmpty || _deliveryAddress == null ? null : _placeOrder,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Buat Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
