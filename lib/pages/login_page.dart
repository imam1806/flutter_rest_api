import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // Import for JSON encoding/decoding

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  // Changed to _usernameController as dummyjson login uses username
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://dummyjson.com/user/login'),
          body: {
            'username': _usernameController.text.trim(),
            'password': _passwordController.text.trim(),
          },
        );

        log(response.body.toString()); // Log the response body for debugging

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final prefs = await SharedPreferences.getInstance();

          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userToken', responseData['accessToken']);
          await prefs.setInt('userId', responseData['id']);
          await prefs.setString(
            'userName',
            responseData['username'],
          ); // Store the username from the API response
          await prefs.setString(
            'userEmail',
            responseData['email'],
          ); // Store the email from the API response
          await prefs.setString(
            'loginTime',
            DateFormat('d MMM yyyy').format(DateTime.now()),
          );

          // Show a success message
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login successful!')));
          }

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          // Handle login error
          final Map<String, dynamic> errorData = json.decode(response.body);
          String errorMessage =
              errorData['message'] ?? 'Login failed. Please try again.';

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          }
        }
      } catch (e) {
        // Handle network or other errors
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
        }
      }
    }
  }

  // Updated validator for username (previously email)
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username wajib diisi';
    // You might want to add more specific username validation if needed
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32), // Increased padding
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              children: [
                Image.asset(
                  'assets/images/logo-login.png',
                  height: 120, // Slightly larger logo
                ),
                const SizedBox(height: 60), // Increased spacing

                Text(
                  'Selamat Datang',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Masuk untuk melanjutkan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),

                // Username (previously Nama Lengkap)
                TextFormField(
                  controller: _usernameController, // Using _usernameController
                  decoration: InputDecoration(
                    labelText: 'Username', // Changed label to Username
                    hintText: 'Masukkan username Anda',
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.lightBlue.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Rounded corners
                      borderSide: BorderSide.none, // No border line
                    ),
                    filled: true,
                    fillColor: Colors.lightBlue.shade50.withValues(
                      alpha: 0.5,
                    ), // Light background color
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 15,
                    ),
                  ),
                  validator: _validateUsername, // Using _validateUsername
                ),
                const SizedBox(height: 20), // Consistent spacing
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.lightBlue.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.lightBlue.shade50.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 15,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 30), // Increased spacing before button
                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _login,
                    icon: const Icon(Icons.login),
                    label: const Text("MASUK"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.lightBlue, // Primary color for the button
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ), // Taller button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Rounded button
                      ),
                      elevation: 5, // Subtle shadow
                      textStyle: const TextStyle(
                        fontSize: 18, // Slightly larger font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Optional: Add a "Forgot Password" or "Register" link
                TextButton(
                  onPressed: () {
                    // Handle forgot password logic or navigation
                    // For dummyjson, there's no "forgot password" API,
                    // so this would be a placeholder for your actual app logic.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Forgot password functionality not implemented in this example.',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: Colors.lightBlue.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
