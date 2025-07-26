import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/edit_profile_page.dart'; // Sesuaikan import path

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Imam Rabbani Budi Putra';
  String userEmail = '';
  String userPhone = '+6281234567890';
  String userAddress = 'GSP B2/27, Bekasi';
  File? _profileImage; // To store the loaded profile image file

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load all data, including image
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // Penting untuk memeriksa mounted
    setState(() {
      userEmail = prefs.getString('userEmail') ?? 'Email belum tersedia';
      // Load the image path
      String? imagePath = prefs.getString('profileImagePath');
      if (imagePath != null) {
        _profileImage = File(imagePath);
      } else {
        _profileImage = null; // Ensure it's null if no path is stored
      }
      // Anda mungkin juga ingin memuat nama, telepon, alamat dari prefs jika dapat diubah di tempat lain
      // Untuk saat ini, mereka hardcode dan diperbarui hanya melalui nilai kembali editProfile
    });
  }

  void _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditProfilePage(
              currentName: userName,
              currentEmail: userEmail,
              currentPhone: userPhone,
              currentAddress: userAddress,
              currentProfileImagePath:
                  _profileImage?.path, // Teruskan jalur gambar profil saat ini
            ),
      ),
    );

    // Setelah kembali dari EditProfilePage, muat ulang semua data
    // Ini memastikan bidang teks dan gambar diperbarui dari SharedPreferences
    await _loadProfileData();

    // Bidang teks diperbarui dari peta hasil yang dikembalikan,
    // tetapi gambar sekarang ditangani oleh _loadProfileData() yang membaca dari SharedPreferences.
    if (result != null && result is Map<String, String>) {
      if (!mounted) return; // Penting untuk memeriksa mounted
      setState(() {
        userName = result['name']!;
        userEmail = result['email']!;
        userPhone = result['phone']!;
        userAddress = result['address']!;
        // Pembaruan gambar dihapus di sini, karena _loadProfileData menanganinya.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tampilkan Gambar Profil
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300], // Latar belakang cadangan
              backgroundImage:
                  _profileImage != null
                      ? FileImage(
                        _profileImage!,
                      ) // Tampilkan gambar yang dipilih dari file
                      : const AssetImage('assets/images/profile.jpg')
                          as ImageProvider, // Gambar aset default
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profil'),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.only(top: 10),
              child: ListTile(
                leading: const Icon(Icons.email),
                title: Text(userEmail),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: Text(userPhone),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.home),
                title: Text(userAddress),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
