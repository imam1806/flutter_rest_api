// lib/model/address_data.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressData {
  final String title;
  final String snippet;
  final LatLng? latLng; // Opsional, jika Anda ingin menyimpan koordinat juga

  AddressData({required this.title, required this.snippet, this.latLng});
}
