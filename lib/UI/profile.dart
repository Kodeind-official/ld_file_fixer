import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '/Auth/loginPage.dart';
import '/UI/detail_foto.dart';
import '/utility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  late int userId;
  File? _imageFile;
  String? _profileImagePath;
  String? Username;

  @override
  void initState() {
    super.initState();
    // Load user ID from SharedPreferences when the page is initialized
    loadUserId();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Get userId from SharedPreferences
    userId = prefs.getInt('userId') ?? 0;
    Username = prefs.getString('username');
    // Load user profile data based on the userId
    loadUserProfile();
    print('Username: $Username');
  }
  

  Future<void> loadUserProfile() async {
    // Fetch user profile data based on the userId
    final url = Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_user_profile.php');
    final response = await http.post(url, body: {'userId': userId.toString()});

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      setState(() {
        // Set the text controllers with the fetched data
        usernameController.text = userData['username'];
        companyNameController.text = userData['company_name'];
        telephoneController.text = userData['telephone'];
        emailController.text = userData['email'];
        lokasiController.text = userData['lokasi'];
        statusController.text = userData['status'];
        if (userData['file_path'] != null) {
          // Prepend the base URL to the file path
          _profileImagePath = 'https://api.verification.lifetimedesign.id/' +
              userData['file_path'];
        }
      });
    } else {
      // Handle error when fetching data
      print('Failed to load user profile data: ${response.statusCode}');
    }
  }

  Future<void> updateUserProfile() async {
    // Construct the updated user profile data
    final updatedData = {
      'userId': userId.toString(),
      'company_name': companyNameController.text,
      'telephone': telephoneController.text,
      'email': emailController.text,
      'username': usernameController.text,
      'lokasi': lokasiController.text,
    };

    // Send a request to update user profile data
    final url = Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_user_profile.php');
    final response = await http.post(url, body: updatedData);

    if (response.statusCode == 200) {
      final responseBody = response.body;

      if (responseBody.contains('Username already exists')) {
        // Handle username already exists error
        print('Username already exists');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Username already exists. Please choose another one.'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (responseBody.contains('User profile updated successfully')) {
        // Handle success
        print('User profile updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorSet.mainGold,
            content: Text('Successfully updated profile'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Check if the username was changed
        if (usernameController.text != Username) {
          // Navigate to login page
          // Navigator.pop(context);
          Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colorSet.mainGold,
              content: Text('Username changed. Please log in again.'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // You can navigate to another page or show a success message here
        }
      } else {
        // Handle other errors
        print('Failed to update user profile: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to update profile'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Handle HTTP errors
      print('Failed to update user profile: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update profile'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<File?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      // Panggil metode uploadImage untuk mengunggah gambar ke server
      await uploadImage(pickedImage);
    }
  }

  Future<void> uploadImage(File imageFile) async {
    // Kompres gambar sebelum mengunggah
    File? compressedImageFile = await compressImage(imageFile);
    if (compressedImageFile == null) {
      print('Failed to compress image');
      return;
    }

    // Mendapatkan informasi tambahan dari controller atau state
    String companyName = companyNameController.text;
    String username = usernameController.text;
    String userIdStr = userId.toString();

    // Buat request HTTP
    final url = Uri.parse(
        'https://api.verification.lifetimedesign.id/save_image_profile_App_FileFixer.php');
    final request = http.MultipartRequest('POST', url);

    // Tambahkan data tambahan ke request
    request.fields['company_name'] = companyName;
    request.fields['username'] = username;
    request.fields['id'] = userIdStr;

    // Tambahkan file gambar ke request
    request.files.add(
        await http.MultipartFile.fromPath('image', compressedImageFile.path));

    // Kirim request
    final response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      // Ambil alamat file dari response server dan bersihkan
      String imagePath = cleanUrl(await response.stream.bytesToString());
      // Perbarui tampilan gambar di aplikasi (opsional)
      setState(() {
        // Perbarui gambar profil dengan yang baru dipilih
        _imageFile = compressedImageFile;
      });
      // Perbarui path gambar di database
      updateUserImagePath(imagePath);
    } else {
      print('Failed to upload image: ${response.reasonPhrase}');
    }
  }

  String cleanUrl(String url) {
    return url.trim();
  }

  Future<File?> compressImage(File imageFile) async {
    // Baca gambar dari file
    final image = img.decodeImage(imageFile.readAsBytesSync());

    // Jika tidak bisa membaca gambar, return null
    if (image == null) return null;

    // Kompres gambar
    final compressedImage = img.encodeJpg(image,
        quality: 50); // Atur kualitas sesuai kebutuhan Anda

    // Simpan gambar yang telah dikompres
    final tempDir = await getTemporaryDirectory();
    final compressedFile =
        File('${tempDir.path}/_File_Fixer_${imageFile.uri.pathSegments.last}');
    compressedFile.writeAsBytesSync(compressedImage);

    return compressedFile;
  }

  Future<void> updateUserImagePath(String imagePath) async {
    // Kirim HTTP request untuk memperbarui path gambar di database
    final url = Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_user_image_path.php');
    final response = await http
        .post(url, body: {'userId': userId.toString(), 'imagePath': imagePath});
    if (response.statusCode == 200) {
      print('successfully updated profile');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colorSet.mainGold,
          content: Text('successfully updated profile'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      print('Failed to update user image path: ${response.reasonPhrase}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed updated profile'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _onWillPop() async {
    Navigator.pop(context, true);
    return false; // Return 'false' untuk mencegah aksi pop default (opsional).
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorSet.pewter,
        appBar: AppBar(
          centerTitle: true,
          // automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
          backgroundColor: Colors.transparent,
          // leading: IconButton(
          //   onPressed: () {
          //     scaffoldKey.currentState?.openDrawer();
          //   },
          //   icon: Image.asset("assets/icons/menu.png"),
          // ),
          title: Text(
            textAlign: TextAlign.center,
            "PROFILE",
            style: ThisTextStyle.bold20MainBg,
          ),
        ),
        // drawer: DrawerLd(username: usernameController.text,companyName : companyNameController.text),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 73,
                      backgroundColor: colorSet.mainGold,
                      child: GestureDetector(
                        onTap: () {
                           Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImagePage(
                                         imageUrls: [_profileImagePath ?? ''],                                        initialIndex: 0,
                                      ),
                                    ));
                        },
                        child: CircleAvatar(
                          backgroundColor: colorSet.mainBG,
                          radius: 70,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_profileImagePath != null
                                      ? NetworkImage(_profileImagePath!)
                                      : AssetImage(
                                          "assets/profiles/profile.png"))
                                  as ImageProvider,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 98.0, left: 116),
                      child: CircleAvatar(
                          radius: 19.5,
                          backgroundColor: colorSet.mainGold,
                          child: Center(
                            child: IconButton(
                                onPressed: () {
                                  _pickImageFromGallery();
                                },
                                icon: Icon(Icons.add, color: colorSet.mainBG,)),
                          )),
                    )
                  ],
                ),
                const Gap(20),
                TextField(
                  // readOnly: true,
                  keyboardType: TextInputType.name,
                  controller: usernameController,
                  textCapitalization: TextCapitalization.characters,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_box),
                    hintText: "Name...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                TextField(
                  readOnly: true,
                  controller: companyNameController,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.business),
                    hintText: "Company Name...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                TextField(
                  keyboardType: TextInputType.phone,
                  controller: telephoneController,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    hintText: "Phone Number...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.mail),
                    hintText: "Email...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const Gap(20),
                TextField(
                  keyboardType: TextInputType.streetAddress,
                  controller: lokasiController,
                  cursorColor: colorSet.mainGold,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.pin_drop),
                    hintText: "Location...",
                    filled: true,
                    fillColor: colorSet.listTile1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
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
                    onPressed: updateUserProfile,
                    child: Text(
                      "Save",
                      style: ThisTextStyle.bold16MainGold,
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
