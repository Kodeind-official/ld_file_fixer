import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import '/Auth/loginPage.dart';
import '/UI/changePasswordPage.dart';
import '/UI/userlist.dart';
import '/super_admin/Vendorpage/vendor_page.dart';
import '/utility.dart';
import '/UI/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageScreen({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Image',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            // Return an empty container if there is an error loading the image
            return Container(child: Center(child: Text('No Image')));
          },
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class DrawerLd extends StatefulWidget {
  final String username;
  final String companyName;

  const DrawerLd({required this.username, required this.companyName, Key? key})
      : super(key: key);

  @override
  _DrawerLdState createState() => _DrawerLdState();
}

class _DrawerLdState extends State<DrawerLd> {
  String selectedButton = 'Home'; // Track the selected button
  late Future<String> _profileImagePathFuture; // Track the profile image path
  String? username;
  String? status;
  String? lokasi;
  String? companyName;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    // Panggil _fetchProfileImagePath saat membangun widget
    _profileImagePathFuture = _fetchProfileImagePath();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      username = prefs.getString('username');
      status = prefs.getString('status');
      lokasi = prefs.getString('lokasi');
      companyName = prefs.getString('companyName');
    });

    print('Id: $userId');
    print('Username: $username');
    print('Status: $status');
    print('Lokasi: $lokasi');
  }

  Future<String> _fetchProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception("User ID not found");
    }

    final url = Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_user_profile.php'); // Sesuaikan URL dengan endpoint Anda
    final response = await http.post(
      url,
      body: {'userId': userId.toString()},
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      return userData['file_path'] ??
          ''; // Mengembalikan file path gambar atau string kosong jika tidak ada
    } else {
      throw Exception("Failed to fetch profile image path");
    }
  }

  Widget _buildProfileImage() {
    return FutureBuilder(
      future: _fetchProfileImagePath(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while waiting for the image path
          return Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colorSet.mainGold,
                child: CircleAvatar(
                  backgroundColor: colorSet.mainBG,
                  radius: 38,
                  backgroundImage: AssetImage(
                    "assets/profiles/profile.png",
                    // package: 'your_package_name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 24),
                child: CircularProgressIndicator(
                  color: colorSet.mainBG,
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          // Display an error message if an error occurs while fetching the image path
          return CircleAvatar(
            radius: 40,
            backgroundColor: colorSet.mainGold,
            child: CircleAvatar(
              backgroundColor: colorSet.mainBG,
              radius: 38,
              backgroundImage: AssetImage(
                "assets/profiles/profile.png",
                // package: 'your_package_name',
              ),
            ),
          );
        } else {
          // Build the profile image after receiving the data
          final String? profileImagePath = snapshot.data as String?;
          // Check if the profile image path is valid
          if (profileImagePath != null && profileImagePath.isNotEmpty) {
            // Add the URL prefix to the image path from the database
            final String fullProfileImagePath =
                'https://api.verification.lifetimedesign.id/$profileImagePath';
            return InkWell(
              onTap: () {
                // Navigate to the full image screen when the image is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullImageScreen(imageUrl: fullProfileImagePath),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: colorSet.mainGold,
                child: CircleAvatar(
                  backgroundColor: colorSet.mainBG,
                  radius: 38,
                  // Display the network image if the URL is not empty
                  backgroundImage: NetworkImage(fullProfileImagePath),
                ),
              ),
            );
          } else {
            // Display the placeholder image if the profile image path is empty
            return InkWell(
              onTap: () {
                // Navigate to the full image screen when the image is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullImageScreen(
                        imageUrl:
                            'assets/profiles/profile.png'), // Example placeholder image
                  ),
                );
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: colorSet.mainGold,
                child: CircleAvatar(
                  backgroundColor: colorSet.mainBG,
                  radius: 38,
                  backgroundImage: AssetImage(
                    "assets/profiles/profile.png",
                    // package: 'your_package_name',
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: colorSet.pewter,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 300,
            child: DrawerHeader(
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    color: Colors.transparent,
                    child: Image.asset("assets/ld_text.png"),
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      _buildProfileImage(),
                      const Gap(20),
                      Flexible(
                        child: SizedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.username.toUpperCase(),
                                style: ThisTextStyle.bold20MainBg,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                status != null
                                    ? status!.capitalizeFirstLetter()
                                    : '',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Container(
                    height: 50,
                    width: 270,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorSet.mainGold,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.companyName,
                        overflow: TextOverflow.ellipsis,
                        style: ThisTextStyle.bold14MainBg,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              buildDrawerButton(
                context: context,
                label: 'Home',
                icon: Icons.home_outlined,
                isSelected: selectedButton == 'Home',
                onPressed: () {
                  setState(() {
                    selectedButton = 'Home';
                  });
                },
              ),
              const Gap(20),
              buildDrawerButton(
                context: context,
                label: 'Profile',
                icon: Icons.graphic_eq_outlined,
                isSelected: selectedButton == 'Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => UpdateProfilePage(),
                    ),
                  ).then((value) {
                    setState(() {
                      // Reload _buildProfileImage here
                      _profileImagePathFuture = _fetchProfileImagePath();
                    });
                  });
                  setState(() {
                    selectedButton = 'Profile';
                  });
                },
              ),
              const Gap(20),
              buildDrawerButton(
                context: context,
                label: 'Password',
                icon: Icons.password,
                isSelected: selectedButton == 'Password',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ChangePasswordPage(),
                    ),
                  );
                  setState(() {
                    selectedButton = 'Password';
                  });
                },
              ),
              if (status != 'procurement' && status != 'vendor') ...[
                const Gap(10),
                buildDrawerButton(
                  context: context,
                  label: 'Users',
                  icon: Icons.people,
                  isSelected: selectedButton == 'Users',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => UserListPage(),
                      ),
                    );
                    setState(() {
                      selectedButton = 'Users';
                    });
                  },
                ),
                const Gap(10),
                buildDrawerButton(
                  context: context,
                  label: 'Company',
                  icon: Icons.business,
                  isSelected: selectedButton == 'Vendor',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => CompanyPage(),
                      ),
                    );
                    setState(() {
                      selectedButton = 'Vendor';
                    });
                  },
                ),
              ],
            ]),
          ),
          const Gap(10),
          const Divider(),
          Container(
            padding: const EdgeInsets.only(left: 20, top: 0, right: 20),
            child: SizedBox(
              height: 60,
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  await _confirmLogoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: colorSet.mainBG,
                    ),
                    const Gap(20),
                    Text(
                      "Logout",
                      style: TextStyle(color: colorSet.mainBG),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorSet.mainGold,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colorSet.listTile2, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text("Logout", style: TextStyle(color: colorSet.mainBG)),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Container(
                  width: 90,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorSet.listTile2,
                  ),
                  child: Center(
                      child: Text("Cancel",
                          style: TextStyle(color: colorSet.mainBG)))),
            ),
            TextButton(
              onPressed: () async {
                // Navigator.of(context).pop(); // Tutup dialog
                await _logout(context); // Lakukan logout
              },
              child: Container(
                  width: 90,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorSet.mainBG,
                  ),
                  child: Center(
                      child: Text(
                    "Yes",
                    style: TextStyle(color: colorSet.mainGold),
                  ))),
            ),
          ],
        );
      },
    );
  }

  ElevatedButton buildDrawerButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? colorSet.mainBG : Colors.transparent,
        elevation: 0,
        side: BorderSide(
          width: 2,
          color: isSelected ? colorSet.mainBG : Colors.transparent,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorSet.mainGold : colorSet.mainBG,
            ),
            const Gap(20),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorSet.mainGold : colorSet.mainBG,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
