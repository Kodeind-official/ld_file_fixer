import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '/Auth/loginPage.dart';
import '/Vendor2/home.dart';
import '/main.dart';
import '/super_admin/home.dart';
import '/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 4),
      () => _checkLoginStatus(context)
    );
   _printFCMToken();
  }

   void _printFCMToken() async {
    // Mendapatkan token FCM
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    // Cek jika token tidak null
    if (fcmToken != null) {
      print('FCM Token: $fcmToken');
      await _saveFCMTokenToPrefs(fcmToken);
       await _saveFCMTokenToDB(fcmToken);
    } else {
      print('Gagal mendapatkan FCM token.');
    }
  }

  Future<void> _saveFCMTokenToDB(String fcmToken) async {
  // Mendapatkan id pengguna dari SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('userId');

  if (userId != null) {
    try {
      final url = Uri.parse('https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_fcm_token.php');
      final response = await http.post(
        url,
        body: {
          'userId': userId.toString(),
          'fcmToken': fcmToken,
        },
      );

      if (response.statusCode == 200) {
        print('Token FCM berhasil disimpan di database.');
      } else {
        print('Gagal menyimpan token FCM di database: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat menyimpan token FCM di database: $e');
    }
  } else {
    print('Gagal menyimpan token FCM di database: UserId tidak ditemukan.');
  }
}


  Future<void> _saveFCMTokenToPrefs(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fcmToken', fcmToken);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: colorSet.mainBG,
      body: SingleChildScrollView(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 280),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 270,
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 90,
                    ),
                  ).animate().fade(delay: 500.ms).slideX(delay: 200.ms),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: double.infinity,
                    color: colorSet.mainGold,
                    child: Center(
                      child: Text(
                        "FILE FIXER",
                        style: ThisTextStyle.bold22MainBg,
                      ),
                    ),
                  ).animate().fade(delay: 1000.ms).slideX(delay: 300.ms)
                ],
              ),
            ),
            const SizedBox(height: 190),
            Text(
              'Trial Version 1.7',
              style: TextStyle(color: colorSet.mainGold),
            ).animate().fade(delay: 1300.ms).scale(delay: 300.ms),
          ],
        ),
      ),
    );
  }
  
  void _checkLoginStatus(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');

  if (userId != null) {
    // Ambil status dari database menggunakan userId
    final status = await _fetchUserStatusFromDB(userId);
    if (status != null) {
      // Pengecekan status pengguna
      if (status == 'vendor') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageVendor2()));
      } else if (status == 'procurement') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageSPA()));
      } else if (status == 'super admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePageSPA()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } else {
      // Jika gagal mendapatkan status dari database
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  } else {
    // Pengguna belum pernah login, tampilkan halaman login
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}

Future<String?> _fetchUserStatusFromDB(int userId) async {
  try {
    final url = Uri.parse('https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_user_status.php');
    final response = await http.post(
      url,
      body: {
        'userId': userId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['status'] as String?;
    } else {
      print('Gagal mendapatkan status dari database: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('Terjadi kesalahan saat mendapatkan status dari database: $e');
    return null;
  }
}
}
