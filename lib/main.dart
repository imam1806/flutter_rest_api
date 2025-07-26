import 'package:flutter/material.dart';
import 'package:flutter_application_1/controller/product_controller.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/dashboard/dashboard_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:flutter_application_1/pages/dashboard/product_detail.dart';
import 'package:flutter_application_1/pages/address_map_page.dart';
import 'package:flutter_application_1/pages/order_confirmation_page.dart';
import 'package:flutter_application_1/pages/order_history_page.dart';
import 'package:flutter_application_1/controller/order_controller.dart'; // <--- Impor OrderController

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Flutter',
      theme: ThemeData.light(),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/dashboard', page: () => const DashboardPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/product_detail', page: () => ProductDetail()),
        GetPage(name: '/address_map_page', page: () => const AddressMapPage()),

        // Halaman CartPage dan CheckoutPage tidak didefinisikan di sini
        // karena mereka dipanggil dengan MaterialPageRoute dan callback
        // dari DashboardPage.
        GetPage(
          name: '/order_confirmation_page',
          page: () {
            final args = Get.arguments;
            if (args != null && args is List && args.length == 4) {
              return OrderConfirmationPage(
                confirmedOrderItems: List<CartItem>.from(args[0]),
                deliveryAddress: args[1],
                paymentMethod: args[2],
                totalAmount: args[3],
              );
            }
            return const Text('Error: Order details not found.');
          },
        ),
        // OrderHistoryPage tidak lagi memerlukan argumen karena mengambil dari OrderController
        GetPage(name: '/order_history_page', page: () => OrderHistoryPage()),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(OrderController());
        Get.put(ProductController());
      }),
    );
  }
}
