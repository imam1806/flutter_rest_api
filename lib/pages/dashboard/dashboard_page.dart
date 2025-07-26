// lib/pages/dashboard_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/address_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

// Import semua halaman dan model/controller yang dibutuhkan
import 'package:flutter_application_1/model/product_model.dart';
import 'package:flutter_application_1/controller/product_controller.dart';
import 'package:flutter_application_1/pages/dashboard/product_detail.dart';
import 'package:flutter_application_1/pages/cart_page.dart';
import 'package:flutter_application_1/controller/order_controller.dart'; // <--- Impor OrderController

// Definisi kelas CartItem (Bisa tetap di sini atau dipindahkan ke file model terpisah jika diinginkan)
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userName = 'Memuat...';
  String _userEmail = 'Memuat...';
  String _loginTime = 'Belum tersedia';
  File? _profileImage;

  final ProductController productController = Get.find();
  final OrderController orderController = Get.find();

  // Daftar untuk menyimpan item yang saat ini ada di keranjang belanja
  final List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _userName = prefs.getString('userName') ?? 'Pengguna';
      _userEmail = prefs.getString('userEmail') ?? 'Email';
      _loginTime = prefs.getString('loginTime') ?? 'Belum tersedia';

      String? imagePath = prefs.getString('profileImagePath');
      if (imagePath != null) {
        _profileImage = File(imagePath);
      } else {
        _profileImage = null;
      }
    });
  }

  void _addToCart(Product product) {
    if (!mounted) {
      return;
    }
    setState(() {
      int existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.title} ditambahkan ke keranjang!')),
      );
    });
  }

  void _removeFromCart(Product product) {
    if (!mounted) {
      return;
    }
    setState(() {
      _cartItems.removeWhere((item) => item.product.id == product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.title} dihapus dari keranjang!')),
      );
    });
  }

  // Callback baru untuk menangani checkout yang berhasil
  void _onCheckoutCompleted(List<CartItem> confirmedItems) {
    if (!mounted) {
      return;
    }
    orderController.addOrder(
      confirmedItems,
    ); // <--- Panggil metode di OrderController
    setState(() {
      // Tetap panggil setState untuk mengosongkan _cartItems
      _cartItems.clear(); // Kosongkan keranjang setelah checkout
    });
  }

  // --- Fungsi Baru: Pembelian Langsung ---
  Future<void> _buyNow(Product product) async {
    // 1. Buat CartItem tunggal untuk pembelian langsung
    final List<CartItem> singleItemOrder = [
      CartItem(product: product, quantity: 1),
    ];

    // 2. Asumsi alamat dan metode pembayaran default
    // Anda bisa mengambil ini dari SharedPreferences atau profil pengguna yang sudah login
    const String defaultPaymentMethod = 'Cash on Delivery (COD)';
    // Pastikan AddressData diimpor jika Anda menggunakan ini
    final AddressData defaultAddress = AddressData(
      title:
          'Alamat Rumah Default', // Sesuaikan atau ambil dari SharedPreferences
      snippet: 'Jl. Contoh No. 123, Bekasi',
      latLng: const LatLng(-6.340583, 107.042056), // Contoh koordinat
    );
    const double defaultShippingCost = 15000.0;
    final double orderTotalAmount =
        singleItemOrder[0].totalPrice + defaultShippingCost;

    // 3. Tambahkan pesanan ke riwayat melalui OrderController
    _onCheckoutCompleted(
      singleItemOrder,
    ); // Ini akan memanggil orderController.addOrder

    // 4. Tampilkan konfirmasi di UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} berhasil dibeli!'),
        backgroundColor: Colors.green,
      ),
    );

    Get.offAllNamed(
      '/order_confirmation_page',
      arguments: [
        singleItemOrder,
        defaultAddress,
        defaultPaymentMethod,
        orderTotalAmount,
      ],
    );
  }
  // --- Akhir Fungsi Pembelian Langsung ---

  void _navigateToCart() async {
    Navigator.pop(context); // Tutup drawer
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CartPage(
              cartItems: _cartItems,
              onRemoveItem: (product) {
                _removeFromCart(product);
              },
              onCheckout: _onCheckoutCompleted, // Teruskan callback baru
            ),
      ),
    );
    if (!mounted) return;
    setState(
      () {},
    ); // Panggil setState untuk memperbarui tampilan keranjang di dashboard
  }

  void _navigateToProductDetail({Product? product}) async {
    await Get.to(() => ProductDetail(initialProduct: product));
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          "Marketplace Saya",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.lightBlueAccent,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang, $_userName 👋",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Temukan berbagai produk menarik di sini!",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Login terakhir: $_loginTime",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Obx(() {
              if (productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (productController.products.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Tidak ada produk tersedia.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 310,
                        ),
                    itemCount: productController.products.length,
                    itemBuilder: (context, index) {
                      final product = productController.products[index];
                      return _buildProductCard(product);
                    },
                  ),
                );
              }
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: TextButton(
        onPressed: () {
          productController.findProduct(product.id!);
          _navigateToProductDetail(product: product);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 150,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.fill,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.category,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.stock}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _addToCart(product),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            side: const BorderSide(color: Colors.indigo),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: const Text(
                            'Keranjang',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // --- Perubahan di sini untuk tombol 'Beli' ---
                            _buyNow(product); // Panggil fungsi beli langsung
                            // --- Akhir perubahan ---
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: const Text(
                            'Beli',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    int cartItemCount = _cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            accountEmail: Text(_userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/images/profile.jpg')
                          as ImageProvider,
            ),
            decoration: const BoxDecoration(color: Colors.lightBlueAccent),
          ),
          _drawerTile(
            icon: Icons.home,
            title: 'Beranda',
            onTap: () => Navigator.pop(context),
          ),
          _drawerTile(
            icon: Icons.person,
            title: 'Profil',
            onTap: () async {
              Navigator.pop(context);
              await Get.toNamed('/profile');
              _loadUserData();
            },
          ),
          _drawerTile(
            icon: Icons.shopping_cart,
            title: 'Keranjang ($cartItemCount)',
            onTap: _navigateToCart,
          ),
          _drawerTile(
            icon: Icons.location_on,
            title: 'Alamat',
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/address_map_page');
            },
          ),
          // Gunakan Obx untuk memperbarui jumlah pesanan secara reaktif
          Obx(
            () => _drawerTile(
              icon: Icons.receipt, // Ikon untuk pesanan
              title:
                  'Pesanan (${orderController.orderHistory.length})', // <--- Ambil dari controller
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Get.toNamed(
                  '/order_history_page',
                ); // <--- Navigasi tanpa meneruskan argumen
              },
            ),
          ),
          _drawerTile(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('isLoggedIn');
              await prefs.remove('userEmail');
              await prefs.remove('userName');
              await prefs.remove('loginTime');
              await prefs.remove('profileImagePath');
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
