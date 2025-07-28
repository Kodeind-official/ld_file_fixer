import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '/UI/detail_foto.dart';
import '/UI/drawer.dart';
import '/Vendor2/detail2.dart';
import '/Vendor2/upload.dart';
import '/main.dart';
import '/super_admin/detail2.dart';
import '/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageVendor2 extends StatefulWidget {
  @override
  State<HomePageVendor2> createState() => _HomePageVendor2State();
}

class _HomePageVendor2State extends State<HomePageVendor2> {
  late Future<List<CustomImageInfo>> _futureImages;
  // ignore: unused_field
  bool _isRefreshing = false;
  bool _searchMode = false;
  String _searchQuery = '';
  bool _isSearching = false;
  String _searchText = '';
  String? username;
  String? status;
  String? lokasi;
  String? companyName;
  int? userId;
  bool isLoading = false;
  DateTime _selectedStartDate = DateTime.now().subtract(Duration(days: 1));
  DateTime _selectedEndDate = DateTime.now();

  Timer? _debounce;

  @override
  // void initState() {
  //   super.initState();
  //   _loadUserInfo();
  //   final yesterday = DateTime.now().subtract(
  //       Duration(days: 1)); // Mengurangi satu hari dari tanggal sekarang
  //   final startOfYesterday =
  //       DateTime(yesterday.year, yesterday.month, yesterday.day);
  //   final endOfYesterday =
  //       DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
  //   _filterByDateRange(startOfYesterday, endOfYesterday);
  //   _checkUser();
  // }


void initState() {
  super.initState();
  _loadUserInfo();
  final DateTime today = DateTime.now();
  final DateTime yesterday = today.subtract(Duration(days: 1));
  
  // Mengatur tanggal awal ke hari ini dan akhir ke kemarin
  final startOfToday = DateTime(today.year, today.month, today.day);
  final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
  
  final startOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
  final endOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
  
  // Menggabungkan gambar dari hari ini dan kemarin
  final todayImages = fetchImagesByDateRange(startOfToday, endOfToday);
  final yesterdayImages = fetchImagesByDateRange(startOfYesterday, endOfYesterday);
  
  // Menggabungkan hasilnya
  _futureImages = Future.wait([todayImages, yesterdayImages]).then((List<List<CustomImageInfo>> results) {
    List<CustomImageInfo> combinedList = [];
    combinedList.addAll(results[0]); // Gambar dari hari ini
    combinedList.addAll(results[1]); // Gambar dari kemarin
    return combinedList;
  });
}

Future<List<CustomImageInfo>> fetchImagesByDateRange(DateTime start, DateTime end) async {
  // Mengambil gambar berdasarkan tanggal unggah dalam rentang tertentu
  final allImages = await fetchImages();
  return allImages.where((image) {
    final uploadDate = DateTime.parse(image.tanggal_upload_hari_ini);
    return uploadDate.isAfter(start) && uploadDate.isBefore(end);
  }).toList();
}
  Future<void> _checkUser() async {
    final response = await http
        .get(Uri.parse('https://menuku.id/flutter/validasifoto/testing.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['exists'] == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TemporaryPage()),
        );
      }
    } else {
      // Handle server error
      print('Failed to check user');
    }
  }

  Future<void> _refreshImages() async {
    if (!mounted) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      _filterByDateRange(_selectedStartDate, _selectedEndDate);
    } catch (e) {
      print('Error refreshing images: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<List<CustomImageInfo>> fetchImages() async {
    final response = await http.get(Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_images.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;

      // Inisialisasi userId dari SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      // Jika userId null, throw Exception
      if (userId == null) {
        throw Exception('userId is null');
      }

      List<CustomImageInfo> imageList = data.map((item) {
        // Format tanggal upload
        final formattedDate = DateFormat('d MMM yyyy HH:mm:ss')
            .format(DateTime.parse(item['upload_date']));
        final formattedDate2 = DateFormat('d MMM yyyy')
            .format(DateTime.parse(item['upload_date']));

        // Membuat objek CustomImageInfo dari data yang diambil
        return CustomImageInfo(
          id: item['id'],
          userIdLogin: item['userId'],
          filePath: item['file_path'],
          uploadDateOri: item['upload_date'],
          uploadDate: formattedDate,
          uploadDate2: formattedDate2,
          companyName: item['company_name'],
          statusIMG: item['status'],
          username: item['username'],
          deskripsi: item['deskripsi'],
          statusReadVendor: item['statusReadVendor'],
          statusReadAdmin: item['statusReadAdmin'],
          deskripsi_status: item['deskripsi_status'],
          tanggal_upload_hari_ini: item['tanggal_upload_pengajuan'],
        );
      }).toList();

      // Filter the images based on the userId
      imageList = imageList
          .where((image) => image.userIdLogin == userId.toString())
          .toList();

      imageList.sort((a, b) => b.id.compareTo(a.id));

      // Filter dan sortir data sesuai dengan kriteria
      if (status == 'vendor') {
        List<CustomImageInfo> vendorImages = imageList
            .where((image) => image.statusReadVendor == 'unread')
            .toList();
        vendorImages.sort((a, b) => DateTime.parse(b.tanggal_upload_hari_ini)
            .compareTo(DateTime.parse(a.tanggal_upload_hari_ini)));
        imageList.removeWhere((image) =>
            image.statusReadVendor == 'unread'); // Remove unread vendor images
        imageList.insertAll(0, vendorImages); // Insert sorted vendor images
      } else if (status == 'super admin' || status == 'procurement') {
        List<CustomImageInfo> adminImages = imageList
            .where((image) => image.statusReadAdmin == 'unread')
            .toList();
        adminImages.sort((a, b) => DateTime.parse(b.tanggal_upload_hari_ini)
            .compareTo(DateTime.parse(a.tanggal_upload_hari_ini)));
        imageList.removeWhere((image) =>
            image.statusReadAdmin == 'unread'); // Remove unread admin images
        imageList.insertAll(
            0, adminImages); // Insert sorted admin images at the beginning
      }

      return imageList;
    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<void> sendNotification(String username, String fcmToken) async {
    // if (fcmToken.isNotEmpty) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAiAk0jOI:APA91bGHlInl1P3I3QDc0txJFPi8WiwiVFB7gLhSw24pQ34ljqKWHlSy6SkDjuuu4JSZXazb9eYWE1TUzc8DTgZ_7y0gEqCIB6mhNPEGeGuAdtPxg2CNSRQh2iRiSyllK8DI3l31fq2B',
    };

    // Send notification
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: jsonEncode({
        'notification': {
          'to': fcmToken,
          'title': 'Pengajuan anda di $status',
          'body': 'Lihat pengajuan...!',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'to': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully to $username');
    } else {
      print(
          'Failed to send notification to $username. Status code: ${response.statusCode}');
    }
    // } else {
    //   print('FCM Token is empty for user $username');
    // }
  }

  Future<void> updateImageStatus(String id, String newStatus,
      {Function()? onSubmit}) async {
    if (newStatus == 'Rejected') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController deskripsiController = TextEditingController();
          bool localIsLoading = false;

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: colorSet.mainGold,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorSet.listTile2, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                title:
                    Text("Rejected", style: TextStyle(color: colorSet.mainBG)),
                content: TextField(
                  controller: deskripsiController,
                  decoration: InputDecoration(
                    fillColor: colorSet.listTile2,
                    filled: true,
                    hintText: "Deskripsi",
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorSet.listTile1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorSet.listTile1),
                    ),
                  ),
                  cursorColor: Colors.black,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 90,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorSet.listTile2,
                      ),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: colorSet.mainBG),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        localIsLoading = true;
                      });

                      await _updateImageStatusWithDescription(
                          id, newStatus, deskripsiController.text);

                      if (mounted) {
                        Navigator.pop(context);
                        if (onSubmit != null) onSubmit();
                      }

                      setState(() {
                        localIsLoading = false;
                      });
                    },
                    child: Container(
                      width: 90,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorSet.mainBG,
                      ),
                      child: Center(
                        child: localIsLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorSet.mainGold),
                              )
                            : Text(
                                "Submit",
                                style: TextStyle(color: colorSet.mainGold),
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      await _updateImageStatusWithDescription(id, newStatus, "");
      if (onSubmit != null) onSubmit();
    }
  }

  Future<void> _updateImageStatusWithDescription(
      String id, String newStatus, String deskripsi) async {
    final response = await http.post(
      Uri.parse(
          'https://api.verification.lifetimedesign.id/update_status_nota_FileFixer.php'),
      body: {
        'id': id,
        'status': newStatus,
        'deskripsi_status':
            deskripsi, // Sertakan deskripsi status dalam body request
      },
    );

    if (response.statusCode == 200) {
      print('Status updated successfully');
      // Setelah berhasil memperbarui status gambar, dapatkan nilai userId dari tabel validasi
      try {
        final userIdResponse = await http.post(
          Uri.parse(
              'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_userid_from_validasi.php'),
          body: {
            'id': id,
          },
        );
        if (userIdResponse.statusCode == 200) {
          final userId = jsonDecode(userIdResponse.body)['userId'] as int?;
          if (userId != null) {
            // Jika userId berhasil ditemukan, panggil fungsi untuk mendapatkan username dan fcmToken
            await getUserInfoAndSendNotification(userId);
          } else {
            print('Failed to find userId for validation id: $id');
          }
        } else {
          print('Failed to fetch userId');
        }
      } catch (e) {
        print('Error getting userId: $e');
      }
      // Tampilkan snackbar setelah berhasil memperbarui Status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colorSet.mainGold,
          content: Text('Status updated successfully!'),
          duration: Duration(seconds: 2), // Atur durasi snackbar di sini
          behavior: SnackBarBehavior.floating, // Atur behavior ke floating
        ),
      );
    } else {
      print('Failed to update status');
      // Tampilkan snackbar jika gagal memperbarui Status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update Status. Please try again.'),
          duration: Duration(seconds: 2), // Atur durasi snackbar di sini
          behavior: SnackBarBehavior.floating, // Atur behavior ke floating
        ),
      );
    }
  }

  Future<void> getUserInfoAndSendNotification(int userId) async {
    try {
      final userInfoResponse = await http.post(
        Uri.parse(
            'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_user_info.php'),
        body: {
          'userId': userId.toString(),
        },
      );
      if (userInfoResponse.statusCode == 200) {
        final userInfo = jsonDecode(userInfoResponse.body);
        final username = userInfo['username'] as String?;
        final fcmToken = userInfo['fcm_token'] as String?;
        print('Username: $username, FCM Token: $fcmToken');
        if (username != null && fcmToken != null) {
          // Kirim notifikasi ke pengguna
          await sendNotification(username, fcmToken);
        } else {
          print('Failed to get username or fcmToken from user info');
        }
      } else {
        print('Failed to fetch user info');
      }
    } catch (e) {
      print('Error getting user info: $e');
    }
  }

  void _handleFilterSelection2(String? selectedValue) {
    setState(() {
      _futureImages = fetchImages().then((images) {
        // Jika selectedValue tidak null, filter gambar berdasarkan status
        if (selectedValue != null && selectedValue.isNotEmpty) {
          images =
              images.where((image) => image.statusIMG == selectedValue).toList();
        }
        // Filter berdasarkan rentang tanggal yang dipilih
        return _filteredList(images);
      });
    });
  }

// void _handleFilterSelection2(String? selectedValue) {
//     setState(() {
//       _futureImages = fetchImages().then((images) {
//         // Jika selectedValue tidak null, filter gambar berdasarkan status
//         if (selectedValue != null && selectedValue.isNotEmpty) {
//           images =
//               images.where((image) => image.status == selectedValue).toList();
//         }
//         return Future.value(images);
//       });
//     });
//   }

  void _handleFilterSelection(String? selectedValue) {
    setState(() {
      if (selectedValue == 'Approved') {
        // Fetch all images with status 'Approved'
        _futureImages = fetchImages().then((images) {
          // Sort the images by upload date
          images.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
          // Take the latest 15 images
          final latestApprovedImages = images.take(30).toList();
          return Future.value(latestApprovedImages);
        });
      } else {
        // For other filter values, fetch all images
        _futureImages = fetchImages();
      }
    });
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

  Future<void> _openUploadPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadImageSPAPage()),
    );

    // Jika hasilnya true, lakukan refresh.
    if (result == true) {
      _refreshImages(); // Fungsi refresh
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      setState(() {
        _searchText = query; // Update _searchText
        _futureImages =
            _filterImages(_searchText); // Use _searchText in filtering
      });
    });
  }

  Future<List<CustomImageInfo>> _filterImages(String query) async {
    final allImages = await fetchImages();
    if (query.isEmpty) {
      return allImages; // Return all images if query is empty
    } else {
      // Filter images based on search query
      return allImages
          .where((image) =>
              image.uploadDateOri.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      onChanged: _onSearchChanged,
      controller: TextEditingController(
          text: _searchText), // Sinkronisasi nilai dengan controller
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: colorSet.mainBG),
        border: InputBorder.none,
      ),
      style: TextStyle(color: colorSet.mainBG),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(9999),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _filterByDateRange(picked.start, picked.end);
    }
  }

  void _filterByDateRange(DateTime start, DateTime end) {
    setState(() {
      _searchText = '';
      _searchMode = true;
      _futureImages = fetchImages().then((images) {
        final filteredImages = images.where((image) {
          final uploadDate = DateTime.parse(image.tanggal_upload_hari_ini);
          return uploadDate.isAfter(start.subtract(const Duration(days: 1))) &&
              uploadDate.isBefore(end.add(const Duration(days: 1)));
        }).toList();
        return Future.value(filteredImages);
      });
    });
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchText = '';
            });
          },
          icon: Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchText = ''; // Clear search text when closing search
            });
          },
          icon: Icon(
            Icons.close, // Change the icon to close icon
            color: colorSet.mainBG,
          ),
        ),
      ];
    } else {
      return [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          icon: Icon(
            Icons.search,
            color: colorSet.mainBG,
          ),
        ),
        IconButton(
          onPressed: () {
            _selectDateRange(context);
          },
          icon: Icon(
            Icons.date_range,
            color: colorSet.mainBG,
          ),
        ),
        ShowModalBottomHome(
          onSelected: _handleFilterSelection2,
        ),
      ];
    }
  }

  // List<CustomImageInfo> _filteredList(List<CustomImageInfo>? data) {
  //   if (data == null || data.isEmpty || _searchText.isEmpty) {
  //     return data ?? [];
  //   } else {
  //     return data
  //         .where((imageInfo) => imageInfo.uploadDateOri
  //             .toLowerCase()
  //             .contains(_searchText.toLowerCase()))
  //         .toList();
  //   }
  // }

  List<CustomImageInfo> _filteredList(List<CustomImageInfo>? data) {
    if (data == null || data.isEmpty) {
      return [];
    } else {
      return data.where((imageInfo) {
        final uploadDate = DateTime.parse(imageInfo.tanggal_upload_hari_ini);
        final matchesSearch = _searchText.isEmpty ||
            imageInfo.tanggal_upload_hari_ini
                .toLowerCase()
                .contains(_searchText.toLowerCase());
        final withinDateRange = uploadDate.isAfter(
                _selectedStartDate.subtract(const Duration(days: 1))) &&
            uploadDate.isBefore(_selectedEndDate.add(const Duration(days: 1)));
        return matchesSearch && withinDateRange;
      }).toList();
    }
  }

  // Future<void> _deleteImage(CustomImageInfo imageInfo) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/delete_image.php'),
  //       body: {
  //         'id': imageInfo.id.toString(),
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       print('Image deleted successfully');
  //       // Tampilkan Snackbar untuk memberi tahu pengguna bahwa gambar telah dihapus
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Image deleted successfully'),
  //           backgroundColor: Colors.green, // Atur warna latar belakang Snackbar
  //         ),
  //       );
  //       // Setelah gambar dihapus, Anda mungkin perlu memperbarui daftar gambar dengan memanggil fungsi _refreshImages
  //       _refreshImages();
  //     } else {
  //       print('Failed to delete image. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error deleting image: $e');
  //   }
  // }

  // void _showDeleteConfirmationDialog(
  //     BuildContext context, CustomImageInfo imageInfo) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: colorSet.mainGold,
  //         shape: RoundedRectangleBorder(
  //           side: BorderSide(color: colorSet.listTile2, width: 2),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         title: Text("Delete Image"),
  //         content: Text("Are you sure you want to delete this image?"),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Tutup dialog
  //             },
  //             child: Container(
  //               width: 90,
  //               height: 40,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(8),
  //                 color: colorSet.listTile2,
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   "Cancel",
  //                   style: TextStyle(color: colorSet.mainBG),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Panggil fungsi untuk menghapus gambar
  //               _deleteImage(imageInfo);
  //               Navigator.of(context).pop(); // Tutup dialog
  //             },
  //             child: Container(
  //                 width: 90,
  //                 height: 40,
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   color: colorSet.mainBG,
  //                 ),
  //                 child: Center(
  //                     child: Text(
  //                   "Yes",
  //                   style: TextStyle(color: colorSet.mainGold),
  //                 ))),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: colorSet.pewter,
      key: scaffoldKey,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: Image.asset("assets/icons/menu.png"),
        ),
        // Ganti tombol pencarian dengan TextField jika sedang dalam mode pencarian
        title: _isSearching
            ? _buildSearchField()
            : Text('HOME', style: ThisTextStyle.bold22MainBg),
        actions: _buildAppBarActions(),
      ),
      drawer: DrawerLd(
          username: username.toString(), companyName: companyName.toString()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadPage,
        label: Text(
          "Add Data",
          style: ThisTextStyle.bold16MainGold,
        ),
        backgroundColor: colorSet.mainBG,
        icon: Icon(
          Icons.add,
          color: colorSet.mainGold,
        ),
      ),
      body: RefreshIndicator(
        color: colorSet.mainBG,
        onRefresh: _refreshImages,
        child: FutureBuilder<List<CustomImageInfo>>(
          future: _futureImages,
          builder: (context, snapshot) {
            final filteredList = _filteredList(snapshot.data);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: colorSet.mainBG,
              ));
            } else if (snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: _refreshImages,
                child: Center(
                  child: Text('Error: Please check your connection'),
                ),
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: filteredList.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    if (index >= filteredList.length) {
                      return SizedBox
                          .shrink(); // Menghindari akses ke indeks di luar batas
                    }
                    final imageInfo = filteredList[index];
                    // final imageInfo = snapshot.data![index];
                    Color containerColor =
                        index.isOdd ? colorSet.listTile2 : colorSet.listTile1;
                    if (status == 'vendor' &&
                        imageInfo.statusReadVendor == 'unread') {
                      containerColor = Colors.green.withOpacity(0.5);
                    } else if ((status == 'procurement' ||
                            status == 'super admin') &&
                        imageInfo.statusReadAdmin == 'unread') {
                      containerColor = Colors.green.withOpacity(0.5);
                    }
                    return GestureDetector(
                      // onLongPress: () {
                      //   _showDeleteConfirmationDialog(context, imageInfo);
                      // },
                      onTap: () {
                        // Arahkan ke DetailPage dengan data CustomImageInfo
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailPage(imageInfo: imageInfo),
                          ),
                        ).then((shouldRefresh) {
                          // Jika shouldRefresh adalah true, refresh halaman
                          if (shouldRefresh == true) {
                            _refreshImages();
                            if (_selectedStartDate !=
                                    DateTime.now()
                                        .subtract(Duration(days: 1)) ||
                                _selectedEndDate != DateTime.now()) {
                              _filterByDateRange(
                                  _selectedStartDate, _selectedEndDate);
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 20, right: 20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: containerColor,
                                  border: Border.all(
                                    color: containerColor ==
                                            Colors.green.withOpacity(0.5)
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: containerColor ==
                                            Colors.green.withOpacity(0.5)
                                        ? 2.0
                                        : 0.0,
                                  )),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FullScreenImagePage(
                                              imageUrls: [
                                                'https://api.verification.lifetimedesign.id/${imageInfo.filePath}',
                                              ],
                                              initialIndex: 0,
                                            ),
                                          ),
                                        ).then((shouldRefresh) {
                                          // Jika shouldRefresh adalah true, refresh halaman
                                          if (shouldRefresh == true) {
                                            _refreshImages();
                                          }
                                        });
                                      },
                                      child: CircleAvatar(
                                        radius:
                                            60, // Adjust the radius to make the CircleAvatar bigger
                                        child: ClipOval(
                                          child: Image.network(
                                            'https://api.verification.lifetimedesign.id/${imageInfo.filePath}',
                                            width:
                                                120, // Adjust the width to match the increased size
                                            height:
                                                120, // Adjust the height to match the increased size
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: Colors.grey[400],
                                                );
                                              }
                                            },
                                            errorBuilder: (BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace) {
                                              return Container(
                                                width: 120,
                                                height: 120,
                                                color: Colors.grey[400],
                                              );
                                            },
                                          ),
                                        ),
                                      )),
                                ),
                                title: Text(
                                  imageInfo.companyName,
                                  style: ThisTextStyle.bold18MainBg,
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                       Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 0.0),
                                            child: Text("NOTA"),
                                          ),
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.only(top: 0.0),
                                          //   child: Text(formatDateYear(imageInfo
                                          //       .tanggal_upload_hari_ini)),
                                          // ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0.0),
                                              child: Text(
                                                "-" + imageInfo.id,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Divider(height: 4,color: colorSet.mainBG,),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          children: [
                                            Text('Price'),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 2),
                                              child: Text('      :  Rp. '),
                                            ),
                                            Expanded(
                                                child: Text(
                                              imageInfo.deskripsi,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text('Nota       :  '),
                                          Text(imageInfo.uploadDate2),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('Upload   :  '),
                                          Expanded(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 0.0),
                                            child: Text(formatDate(imageInfo
                                                .tanggal_upload_hari_ini)),
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Container(
                                  width: 90, // Set the desired width
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        getColorBasedOnStatus(imageInfo.statusIMG)
                                            .withOpacity(0.3),
                                    border: Border.all(
                                      color: getColorBasedOnStatus(
                                          imageInfo.statusIMG),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Container(
                                        child: Text(
                                          imageInfo
                                              .statusIMG, // Display the current status
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorSet.mainBG,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM yyyy').format(parsedDate);
  }

  Color getColorBasedOnStatus(String status) {
    switch (status) {
      case 'Waiting':
        return Colors.yellow.withOpacity(0.75); // Light yellow
      // case 'Process':
      //   return Colors.grey.withOpacity(0.75); // Light purple
      case 'Approved':
        return Colors.green.withOpacity(0.75); // Light green
      case 'Rejected':
        return Colors.red.withOpacity(0.75); // Light red
      default:
        return Colors.grey.withOpacity(0.75); // Default color
    }
  }
}

class ShowModalBottomHome extends StatefulWidget {
  final Function(String?) onSelected;

  const ShowModalBottomHome({super.key, required this.onSelected});

  @override
  State<ShowModalBottomHome> createState() => _ShowModalBottomHomeState();
}

class _ShowModalBottomHomeState extends State<ShowModalBottomHome> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile(
                        title: const Text('Approved'),
                        value: 'Approved',
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value as String?;
                          });
                        },
                        activeColor:
                            Colors.green, // Warna radio button saat terpilih
                        selected: _selectedValue == 'Approved',
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      RadioListTile(
                        title: const Text('Waiting'),
                        value: 'Waiting',
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value as String?;
                          });
                        },
                        activeColor:
                            Colors.yellow, // Warna radio button saat terpilih
                        selected: _selectedValue == 'Waiting',
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      // RadioListTile(
                      //   title: const Text('Process'),
                      //   value: 'Process',
                      //   groupValue: _selectedValue,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _selectedValue = value as String?;
                      //     });
                      //   },
                      //   activeColor:
                      //       Colors.grey, // Warna radio button saat terpilih
                      //   selected: _selectedValue == 'Process',
                      //   controlAffinity: ListTileControlAffinity.trailing,
                      // ),
                      RadioListTile(
                        title: const Text('Rejected'),
                        value: 'Rejected',
                        groupValue: _selectedValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value as String?;
                          });
                        },
                        activeColor:
                            Colors.red, // Warna radio button saat terpilih
                        selected: _selectedValue == 'Rejected',
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            // Aksi ketika tombol ditekan di dalam BottomSheet
                            if (_selectedValue != null) {
                              widget.onSelected(_selectedValue);
                              print('Pilihan yang dipilih: $_selectedValue');
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorSet.mainBG,
                            elevation: 0,
                            side: BorderSide(width: 2, color: colorSet.mainBG),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: ThisTextStyle.bold16MainGold,
                          ),
                        ),
                      ),
                      const Gap(40)
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      icon: Image.asset(
        "assets/icons/sort3.png",
        width: 32,
      ),
    );
  }
}
