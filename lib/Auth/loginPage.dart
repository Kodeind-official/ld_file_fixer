import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '/Vendor2/home.dart';
import '/super_admin/home.dart';
import '/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _printFCMToken();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> _saveFCMTokenToDB(String fcmToken) async {
    // Mendapatkan id pengguna dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      try {
        final url = Uri.parse(
            'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_fcm_token.php');
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
          print(
              'Gagal menyimpan token FCM di database: ${response.reasonPhrase}');
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

  void _printFCMToken() async {
    // Mendapatkan token FCM
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    // Cek jika token tidak null
    if (fcmToken != null) {
      print('FCM Token: $fcmToken');
    } else {
      print('Gagal mendapatkan FCM token.');
    }
  }

  @override
  Widget build(BuildContext context) {
    //  final _formKey = GlobalKey<FormState>();
    // final TextEditingController _usernameController = TextEditingController();
    // final TextEditingController _passwordController = TextEditingController();
    bool _isLoading = false;

    Future<void> _login() async {
      setState(() {
        _isLoading = true;
      });

      final username = _usernameController.text;
      final password = _passwordController.text;
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      final url =
          'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/login.php';

      final response = await http.post(
        Uri.parse(url),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('userId') && fcmToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', data['userId']);
          await prefs.setString('username', username);
          await prefs.setString('status', data['status']);
          await prefs.setString('lokasi', data['lokasi']);
          await prefs.setString('companyName', data['companyName']);
          await prefs.setString('telephone', data['telephone']);
          // await prefs.setString('email', data['email']);
          // await prefs.setString('fcmToken', data['fcmToken']);

          // await _saveFCMTokenToPrefs(data['fcmToken']);
          // await _saveFCMTokenToDB(data['fcmToken']);
          await _saveFCMTokenToPrefs(fcmToken);
          await _saveFCMTokenToDB(fcmToken);

          if (data['status'] == 'vendor') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => HomePageVendor2()));
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text('Login Successful'),
            //     duration:
            //         const Duration(seconds: 2), // Adjust the duration as needed
            //   ),
            // );
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => HomePageSPA()));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colorSet.mainGold,
              content: Text('Login Successful'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Incorrect username or password'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Terjadi kesalahan saat melakukan login'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/bg_ld2.jpg"), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SizedBox(
              height: 400,
              width: 300,
              child: Column(
                children: [
                  SizedBox(
                    child: Image.asset("assets/ld_text.png"),
                  ).animate().fade(delay: 1000.ms).slide(delay: 500.ms),
                  const SizedBox(height: 70),
                  TextField(
                    textCapitalization: TextCapitalization.characters,
                    controller: _usernameController,
                    style: TextStyle(color: colorSet.mainGold),
                    cursorColor: colorSet.mainGold,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.people,
                        color: colorSet.mainGold,
                      ),
                      hintText: "Username",
                      hintStyle: const TextStyle(color: Colors.white38),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorSet.mainGold),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorSet.mainGold),
                      ),
                    ),
                  ).animate().fade(delay: 200.ms).slide(),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _passwordController,
                    style: TextStyle(color: colorSet.mainGold),
                    cursorColor: colorSet.mainGold,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.password_rounded,
                        color: colorSet.mainGold,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colorSet.mainGold,
                        ),
                      ),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.white38),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorSet.mainGold),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorSet.mainGold),
                      ),
                    ),
                    obscureText: _obscureText,
                  ).animate().fade(delay: 400.ms).slide(),
                  const SizedBox(height: 50),
                  Container(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorSet.mainGold,
                        textStyle: const TextStyle(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ).animate().fade(delay: 800.ms).slide(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
