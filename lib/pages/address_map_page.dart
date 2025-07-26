// lib/pages/address_map_page.dart
import 'dart:async'; // Untuk Completer
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Impor Google Maps
import 'package:geolocator/geolocator.dart'; // Impor geolocator
import 'package:get/get.dart'; // Impor GetX untuk snackbar
import 'package:flutter_application_1/model/address_data.dart'; // Impor model AddressData

class AddressMapPage extends StatefulWidget {
  const AddressMapPage({super.key});

  @override
  State<AddressMapPage> createState() => _AddressMapPageState();
}

class _AddressMapPageState extends State<AddressMapPage> {
  final Completer<GoogleMapController> _completer = Completer();
  GoogleMapController? _mapController;

  // Posisi RUMAH (menggunakan koordinat yang Anda berikan, diubah ke desimal)
  final CameraPosition _homePosition = const CameraPosition(
    target: LatLng(
      -6.340583, // Latitude Rumah Anda
      107.042056, // Longitude Rumah Anda
    ),
    zoom: 16.0,
  );

  // Posisi STMIK Bani Saleh (berdasarkan PDF)
  final CameraPosition _stmikPosition = const CameraPosition(
    target: LatLng(
      -6.25217079640056,
      107.00269487400477,
    ),
    zoom: 18.0,
  );

  final RxSet<Marker> _markers = RxSet<Marker>();
  AddressData? _selectedAddress; // Menyimpan alamat yang saat ini dipilih/ditampilkan

  @override
  void initState() {
    super.initState();
    // Tambahkan marker awal untuk RUMAH saat inisialisasi
    _addMarker(
      markerId: 'homeAddress',
      position: _homePosition.target,
      title: 'Rumah Saya',
      snippet: 'Alamat Tinggal Anda',
      hue: BitmapDescriptor.hueBlue,
    );
    // Set alamat awal yang dipilih sebagai rumah
    _selectedAddress = AddressData(
      title: 'Rumah Saya',
      snippet: 'Alamat Tinggal Anda',
      latLng: _homePosition.target,
    );
  }

  void _addMarker({
    required String markerId,
    required LatLng position,
    String? title,
    String? snippet,
    double hue = BitmapDescriptor.hueRed,
  }) {
    _markers.clear(); // Hapus marker sebelumnya
    final newMarker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
    );
    _markers.add(newMarker);

    // Update alamat yang dipilih
    _selectedAddress = AddressData(
      title: title ?? 'Lokasi Dipilih',
      snippet: snippet ?? 'Koordinat: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      latLng: position,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _completer.complete(controller);
    _mapController = controller;
  }

  Future<void> _goToHome() async {
    final GoogleMapController controller = await _completer.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_homePosition));
    _addMarker(
      markerId: 'homeAddress',
      position: _homePosition.target,
      title: 'Rumah Saya',
      snippet: 'Alamat Tinggal Anda',
      hue: BitmapDescriptor.hueBlue,
    );
  }

  Future<void> _goToStmik() async {
    final GoogleMapController controller = await _completer.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_stmikPosition));
    _addMarker(
      markerId: 'stmikAddress',
      position: _stmikPosition.target,
      title: 'STMIK Bani Saleh',
      snippet: 'Kampus IT Biru di Bekasi',
      hue: BitmapDescriptor.hueRed,
    );
  }

  Future<void> _goCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        "Lokasi tidak aktif",
        "Silakan aktifkan GPS Anda di pengaturan perangkat.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          "Izin lokasi ditolak",
          "Anda perlu memberikan izin lokasi untuk menggunakan fitur ini.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Izin lokasi ditolak permanen",
        "Silakan buka pengaturan aplikasi dan berikan izin lokasi secara manual.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final GoogleMapController controller = await _completer.future;
    CameraPosition newPosition = CameraPosition(
      target: LatLng(currentPosition.latitude, currentPosition.longitude),
      zoom: 18.0,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));

    _addMarker(
      markerId: 'currentLocation',
      position: LatLng(currentPosition.latitude, currentPosition.longitude),
      title: 'Lokasi Anda Saat Ini',
      snippet: 'Posisi terkini berdasarkan GPS',
      hue: BitmapDescriptor.hueGreen,
    );

    Get.snackbar(
      "Lokasi Terkini",
      "Berhasil menemukan lokasi Anda.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Metode untuk menangani tap pada peta
  void _onMapTap(LatLng latLng) {
    setState(() {
      _addMarker(
        markerId: 'tappedLocation',
        position: latLng,
        title: 'Lokasi Dipilih',
        snippet: 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}',
        hue: BitmapDescriptor.hueOrange, // Warna oranye untuk lokasi yang ditap
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Pengiriman'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () => Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _homePosition,
              markers: _markers.value,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: _onMapTap, // Tambahkan onTap
            ),
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'btnHome',
                      onPressed: _goToHome,
                      label: const Text('Rumah'),
                      icon: const Icon(Icons.home),
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                    ),
                    FloatingActionButton.extended(
                      heroTag: 'btnCurrent',
                      onPressed: _goCurrentLocation,
                      label: const Text('Terkini'),
                      icon: const Icon(Icons.my_location),
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                    ),
                    FloatingActionButton.extended(
                      heroTag: 'btnStmik',
                      onPressed: _goToStmik,
                      label: const Text('STMIK'),
                      icon: const Icon(Icons.school),
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: SafeArea(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Lokasi Terpilih:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _selectedAddress?.title ?? 'Belum ada lokasi dipilih',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          _selectedAddress?.snippet ?? 'Ketuk pada peta atau pilih opsi di bawah.',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedAddress != null
                                ? () {
                                    Navigator.pop(context, _selectedAddress); // Kembali dengan data alamat
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Konfirmasi Lokasi Ini'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
