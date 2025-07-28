import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/Auth/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _logout(context);
          },
          child: Text('Logout'),
        ),
      ),
    );
  }

  // Fungsi logout
  Future<void> _logout(BuildContext context) async {
    // Ambil instance dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Dapatkan ID pengguna saat ini (misalnya dari SharedPreferences)
    final userId =
        prefs.getInt('userId'); // Ganti dengan cara Anda mengambil ID pengguna

    // Update kolom `fcm_token` di database menjadi kosong untuk pengguna yang sedang login
    await _updateFcmToken(userId);

    // Hapus semua data dalam SharedPreferences
    await prefs.clear();

    // Arahkan pengguna ke halaman login atau beranda
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        (Route<dynamic> route) => false);
  }

  // Fungsi untuk memperbarui `fcm_token` menjadi kosong di database
  Future<void> _updateFcmToken(int? userId) async {
    if (userId == null) {
      return;
    }

    // API endpoint untuk menghapus `fcm_token`
    final url = Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_fcm_token.php');

    // Kirim permintaan POST ke API endpoint
    final response = await http.post(
      url,
      body: {
        'userId': userId.toString(),
        'fcmToken': '', // Set fcm_token menjadi kosong
      },
    );

    if (response.statusCode == 200) {
      print('Token FCM berhasil disimpan di database.');
    } else {
      // Menangani kesalahan jika ada
      print('Gagal mengupdate fcm_token');
    }
  }
}
