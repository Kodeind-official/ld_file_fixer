import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import '/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  int? userId;
  bool _obscureTextCurrentPassword = true;
  bool _obscureTextNewPassword = true;
  bool _obscureTextConfirmPassword = true;
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      // username = prefs.getString('username');
      // status = prefs.getString('status');
      // lokasi = prefs.getString('lokasi');
      // companyName = prefs.getString('companyName');
    });

    print('Id: $userId');
    // print('Username: $username');
    // print('Status: $status');
    // print('Lokasi: $lokasi');
  }

  void _changePassword(BuildContext context) async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Check if current password field is empty
    if (currentPassword.isEmpty) {
      _showSnackbar(context, 'Please enter your current password');
      return;
    }

    // Check if new password field is empty
    if (newPassword.isEmpty) {
      _showSnackbar(context, 'Please enter your new password');
      return;
    }

    // Check if confirm password field is empty
    if (confirmPassword.isEmpty) {
      _showSnackbar(context, 'Please re-enter your new password');
      return;
    }

    // Check if new password matches confirm password
    if (newPassword != confirmPassword) {
      _showSnackbar(context, 'New password and confirm password do not match');
      return;
    }

    // Prepare data for the HTTP request
    var requestBody = {
      'current_password': currentPassword,
      'new_password': newPassword,
      'userId': userId.toString(), // Add the userId to the request
      // Add any additional parameters needed for your API endpoint
    };

    // Make a POST request to your API endpoint
    var url =
        Uri.parse('https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/change_password.php');
    var response = await http.post(url, body: requestBody);

    // Handle success and error responses
    if (response.statusCode == 200) {
      // Password changed successfully
      _showSnackbar(context, 'Password changed successfully',
          color: colorSet.mainGold);
      // Clear all text fields after a delay
      Timer(Duration(milliseconds: 1500), () {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      // Failed to change password
      _showSnackbar(
          context, 'Failed to change password. Please try again later.',
          color: Colors.red);
    }
  }

  void _showSnackbar(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorSet.pewter,
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "CHANGE PASSWORD",
          style: ThisTextStyle.bold20MainBg,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _currentPasswordController,
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.check_box),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextCurrentPassword =
                            !_obscureTextCurrentPassword;
                      });
                    },
                  ),
                  hintText: "Current Password...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                obscureText: _obscureTextCurrentPassword,
              ),
              const Gap(20),
              TextField(
                controller: _newPasswordController,
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextNewPassword = !_obscureTextNewPassword;
                      });
                    },
                  ),
                  hintText: "New Password...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                obscureText: _obscureTextNewPassword,
              ),
              const Gap(20),
              TextField(
                controller: _confirmPasswordController,
                cursorColor: colorSet.mainGold,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.new_releases),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextConfirmPassword =
                            !_obscureTextConfirmPassword;
                      });
                    },
                  ),
                  hintText: "Re-enter New Password...",
                  filled: true,
                  fillColor: colorSet.listTile1,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                obscureText: _obscureTextConfirmPassword,
              ),
              const Gap(20),
              Container(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorSet.mainBG,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    _changePassword(context);
                  },
                  child: Text(
                    "Save",
                    style: ThisTextStyle.bold16MainGold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
