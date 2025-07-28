import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '/UI/detail_foto.dart';
import '/UI/drawer.dart';
import '/super_admin/detail2.dart';
import '/super_admin/upload.dart';
import '/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageSPA extends StatefulWidget {
  @override
  State<HomePageSPA> createState() => _HomePageSPAState();
}

class _HomePageSPAState extends State<HomePageSPA> {
  late Future<List<CustomImageInfo>> _futureImages;
  late FirebaseMessaging _firebaseMessaging;
  // ignore: unused_field
  bool _isRefreshing = false;
  bool _searchMode = false;
  String _searchQuery = '';
  bool _isSearching = false;

  String _searchText = '';
  String? username;
  String? status;
  String? statusIMG;
  String? lokasi;
  String? companyName;
  int? userId;
  bool isLoading = false;
  DateTime _selectedStartDate = DateTime.now().subtract(Duration(days: 1));
  DateTime _selectedEndDate = DateTime.now();
  DateTime _defaultStartDate = DateTime.now().subtract(Duration(days: 1));
  DateTime _defaultEndDate = DateTime.now();

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
  // }

  void initState() {
    super.initState();
    _loadUserInfo();
    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(Duration(days: 1));

    // Mengatur tanggal awal ke hari ini dan akhir ke kemarin
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final startOfYesterday =
        DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfYesterday =
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

    // Menggabungkan gambar dari hari ini dan kemarin
    final todayImages = fetchImagesByDateRange(startOfToday, endOfToday);
    final yesterdayImages =
        fetchImagesByDateRange(startOfYesterday, endOfYesterday);

    // Menggabungkan hasilnya
    _futureImages = Future.wait([todayImages, yesterdayImages])
        .then((List<List<CustomImageInfo>> results) {
      List<CustomImageInfo> combinedList = [];
      combinedList.addAll(results[0]); // Gambar dari hari ini
      combinedList.addAll(results[1]); // Gambar dari kemarin
      return combinedList;
    });
  }

// Fungsi untuk menyimpan data ke dalam SharedPreferences
  Future<void> saveDataToSharedPreferences(
      CustomImageInfo selectedImage, String newStatus) async {
    if (selectedImage != null &&
        selectedImage.id != null &&
        selectedImage.userIdLogin != null &&
        selectedImage.filePath != null &&
        selectedImage.uploadDateOri != null &&
        selectedImage.uploadDate != null &&
        selectedImage.uploadDate2 != null &&
        selectedImage.companyName != null &&
        selectedImage.deskripsi != null &&
        selectedImage.username != null &&
        selectedImage.statusReadVendor != null &&
        selectedImage.statusReadAdmin != null &&
        selectedImage.tanggal_upload_hari_ini != null &&
        selectedImage.deskripsi_status != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_id', selectedImage.id);
      await prefs.setString('user_id_login', selectedImage.userIdLogin);
      await prefs.setString('file_path', selectedImage.filePath);
      await prefs.setString('upload_date_ori', selectedImage.uploadDateOri);
      await prefs.setString('upload_date', selectedImage.uploadDate);
      await prefs.setString('upload_date_2', selectedImage.uploadDate2);
      await prefs.setString('company_name', selectedImage.companyName);
      await prefs.setString('status_img', newStatus);
      await prefs.setString('deskripsi', selectedImage.deskripsi);
      await prefs.setString('usernameImage', selectedImage.username);
      await prefs.setString(
          'status_read_vendor', selectedImage.statusReadVendor);
      await prefs.setString('status_read_admin', selectedImage.statusReadAdmin);
      await prefs.setString(
          'tanggal_upload_hari_ini', selectedImage.tanggal_upload_hari_ini);
      await prefs.setString('deskripsi_status', selectedImage.deskripsi_status);
    } else {
      print('Failed to save data to SharedPreferences: Some data is null');
    }
  }

// Fungsi untuk menghapus data dari SharedPreferences
  Future<void> clearDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('image_id');
    await prefs.remove('user_id_login');
    await prefs.remove('file_path');
    await prefs.remove('upload_date_ori');
    await prefs.remove('upload_date');
    await prefs.remove('upload_date_2');
    await prefs.remove('company_name');
    await prefs.remove('status_img');
    await prefs.remove('deskripsi');
    await prefs.remove('usernameImage');
    await prefs.remove('status_read_vendor');
    await prefs.remove('status_read_admin');
    await prefs.remove('tanggal_upload_hari_ini');
    await prefs.remove('deskripsi_status');
  }

// Fungsi untuk mengirim notifikasi
  // Future<void> sendNotificationWithData(CustomImageInfo selectedImage) async {
  //   // Implementasikan logika untuk mengirim notifikasi
  //   // Contoh dengan menggunakan firebase_messaging
  //   await FirebaseMessaging.instance.sendMessage(
  //     data: {
  //       'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //       'image_id': selectedImage.id,
  //       'user_id_login': selectedImage.userIdLogin,
  //       'file_path': selectedImage.filePath,
  //       'upload_date_ori': selectedImage.uploadDateOri,
  //       'upload_date': selectedImage.uploadDate,
  //       'upload_date_2': selectedImage.uploadDate2,
  //       'company_name': selectedImage.companyName,
  //       'status_img': selectedImage.statusIMG,
  //       'deskripsi': selectedImage.deskripsi,
  //       'username': selectedImage.username,
  //       'status_read_vendor': selectedImage.statusReadVendor,
  //       'status_read_admin': selectedImage.statusReadAdmin,
  //       'tanggal_upload_hari_ini': selectedImage.tanggal_upload_hari_ini,
  //       'deskripsi_status': selectedImage.deskripsi_status,
  //     },
  //   );
  // }

  Future<List<CustomImageInfo>> fetchImagesByDateRange(
      DateTime start, DateTime end) async {
    // Mengambil gambar berdasarkan tanggal unggah dalam rentang tertentu
    final allImages = await fetchImages();
    return allImages.where((image) {
      final uploadDate = DateTime.parse(image.tanggal_upload_hari_ini);
      return uploadDate.isAfter(start) && uploadDate.isBefore(end);
    }).toList();
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
        // 'https://menuku.id/flutter/validasifoto/App_File_Fixer/get_images.php'));
        // 'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/dummy_get_images.php'));

        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/dummy_get_images.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;

      List<CustomImageInfo> imageList = data.map((item) {
        // Format tanggal upload
        final formattedDate = DateFormat('d MMM yyyy HH:mm:ss')
            .format(DateTime.parse(item['upload_date']));
        final formattedDate2 = DateFormat('d MMM yyyy')
            .format(DateTime.parse(item['upload_date']));
        // final formattedDate3 = DateFormat('d MMM yyyy HH:mm:ss')
        //     .format(DateTime.parse(item['tanggal_upload_pengajuan'].toString()));

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
            tanggal_upload_hari_ini: item['tanggal_upload_pengajuan']);
      }).toList();

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
        imageList.insertAll(0, vendorImages); // Insert sorted admi
      } else if (status == 'super admin' && status == 'procurement') {
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

  Future<void> sendNotification(String username, String fcmToken, String status,
      String newStatus, String companyName, String deskripsiImage) async {
    final prefs = await SharedPreferences.getInstance();

    String? imageId = prefs.getString('image_id');
    String? userIdLogin = prefs.getString('user_id_login');
    String? filePath = prefs.getString('file_path');
    String? uploadDateOri = prefs.getString('upload_date_ori');
    String? uploadDate = prefs.getString('upload_date');
    String? uploadDate2 = prefs.getString('upload_date_2');
    String? companyName = prefs.getString('company_name');
    String? statusIMG = prefs.getString('status_img');
    String? deskripsi = prefs.getString('deskripsi');
    String? username = prefs.getString('username');
    String? statusReadVendor = prefs.getString('status_read_vendor');
    String? statusReadAdmin = prefs.getString('status_read_admin');
    String? tanggalUploadHariIni = prefs.getString('tanggal_upload_hari_ini');
    // String? deskripsiStatus = prefs.getString('deskripsi_status');

    if (statusIMG == 'Rejected') {
      filePath = filePath?.replaceFirst('uploads', 'Reject');
    }
    if (statusIMG == 'Approved') {
      filePath = filePath?.replaceFirst('Reject', 'uploads');
    }

    print('Data to be sent in notification:');
    print('image_id: $imageId');
    print('user_id: $userIdLogin');
    print('file_path: $filePath');
    print('upload_date_ori: $uploadDateOri');
    print('upload_date: $uploadDate');
    print('upload_date_2: $uploadDate2');
    print('company_name: $companyName');
    print('status: $statusIMG');
    print('description: $deskripsi');
    print('username: $username');
    print('status_read_vendor: $statusReadVendor');
    print('status_read_admin: $statusReadAdmin');
    print('tanggal_upload_hari_ini: $tanggalUploadHariIni');
    print('description_status: $deskripsiImage');

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
          'title': '$statusIMG',
          'body': 'Ketuk untuk lihat pengajuan anda...!',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'image_id': imageId,
          'user_id': userIdLogin,
          'file_path': filePath,
          'upload_date_ori': uploadDateOri,
          'upload_date': uploadDate,
          'upload_date_2': uploadDate2,
          'company_name': companyName,
          'status': statusIMG,
          'description': deskripsi,
          'username': username,
          'status_read_vendor': statusReadVendor,
          'status_read_admin': statusReadAdmin,
          'tanggal_upload_hari_ini': tanggalUploadHariIni,
          'description_status': deskripsiImage,
        },
        'to': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully to $username');
      await clearDataFromSharedPreferences();
    } else {
      print(
          'Failed to send notification to $username. Status code: ${response.statusCode}');
    }
    // } else {
    //   print('FCM Token is empty for user $username');
    // }
  }

  // Future<void> updateImageStatus(String id, String newStatus,
  //     {Function()? onSubmit}) async {
  //   if (newStatus == 'Rejected') {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         TextEditingController deskripsiController = TextEditingController();
  //         bool localIsLoading = false;

  //         return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //             return AlertDialog(
  //               backgroundColor: colorSet.mainGold,
  //               shape: RoundedRectangleBorder(
  //                 side: BorderSide(color: colorSet.listTile2, width: 2),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               title:
  //                   Text("Rejected", style: TextStyle(color: colorSet.mainBG)),
  //               content: TextField(
  //                 controller: deskripsiController,
  //                 decoration: InputDecoration(
  //                   fillColor: colorSet.listTile2,
  //                   filled: true,
  //                   hintText: "Deskripsi",
  //                   labelStyle: TextStyle(color: Colors.black),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide: BorderSide(color: colorSet.listTile1),
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderSide: BorderSide(color: colorSet.listTile1),
  //                   ),
  //                 ),
  //                 cursorColor: Colors.black,
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: Container(
  //                     width: 90,
  //                     height: 40,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(8),
  //                       color: colorSet.listTile2,
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         "Cancel",
  //                         style: TextStyle(color: colorSet.mainBG),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 TextButton(
  //                   onPressed: () async {
  //                     setState(() {
  //                       localIsLoading = true;
  //                     });

  //                     await _updateImageStatusWithDescription(
  //                         id, newStatus, deskripsiController.text);

  //                     if (mounted) {
  //                       Navigator.pop(context);
  //                       if (onSubmit != null) onSubmit();
  //                     }

  //                     setState(() {
  //                       localIsLoading = false;
  //                     });
  //                   },
  //                   child: Container(
  //                     width: 90,
  //                     height: 40,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(8),
  //                       color: colorSet.mainBG,
  //                     ),
  //                     child: Center(
  //                       child: localIsLoading
  //                           ? CircularProgressIndicator(
  //                               valueColor: AlwaysStoppedAnimation<Color>(
  //                                   colorSet.mainGold),
  //                             )
  //                           : Text(
  //                               "Submit",
  //                               style: TextStyle(color: colorSet.mainGold),
  //                             ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       },
  //     );
  //   } else {
  //     await _updateImageStatusWithDescription(id, newStatus, "");
  //     if (onSubmit != null) onSubmit();
  //   }
  // }

  Future<void> updateImageStatus(
      String id, String newStatus, List<CustomImageInfo> snapshot,
      {Function()? onSubmit}) async {
    if (newStatus == 'Rejected') {
      CustomImageInfo? selectedImage;
      for (var imageInfo in snapshot) {
        if (imageInfo.id == id) {
          selectedImage = imageInfo;
          break;
        }
      }

      // Cetak informasi gambar yang diperbarui
      if (selectedImage != null) {
        print('Updated status of image ${selectedImage.id} to $newStatus');
        saveDataToSharedPreferences(selectedImage, newStatus);
      }

      showDialog(
        barrierDismissible: false,
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
                  autofocus: true,
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
                    onPressed: () async {
                      // await clearDataFromSharedPreferences();
                      Navigator.pop(context);
                      await clearDataFromSharedPreferences();
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
                      CustomImageInfo? selectedImage;
                      for (var imageInfo in snapshot) {
                        if (imageInfo.id == id) {
                          selectedImage = imageInfo;
                          break;
                        }
                      }

                      if (selectedImage != null) {
                        updateStatusReadAdmin(selectedImage.id);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        if (onSubmit != null) onSubmit();
                      }

                      setState(() {
                        localIsLoading = false;
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => HomePageSPA()),
                            (Route route) => false);
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
    } else if (newStatus == 'Approved') {
      CustomImageInfo? selectedImage;
      for (var imageInfo in snapshot) {
        if (imageInfo.id == id) {
          selectedImage = imageInfo;
          break;
        }
      }

      if (selectedImage != null) {
        await saveDataToSharedPreferences(selectedImage, newStatus);
        print(
            'Saved data to SharedPreferences: $selectedImage, Status: $newStatus');
      }
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: colorSet.mainGold,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colorSet.listTile2, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            title:
                Text("Confirmation", style: TextStyle(color: colorSet.mainBG)),
            content: Text("Are you sure you want to approve this image?"),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await clearDataFromSharedPreferences();
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
                  // Navigator.pop(context);
                  await _updateImageStatusWithDescription(id, newStatus, "");

                  CustomImageInfo? selectedImage;
                  for (var imageInfo in snapshot) {
                    if (imageInfo.id == id) {
                      selectedImage = imageInfo;
                      break;
                    }
                  }

                  if (selectedImage != null) {
                    updateStatusReadAdmin(selectedImage.id);
                  }

                  if (onSubmit != null) onSubmit();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomePageSPA()),
                      (Route route) => false);
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
                      "Approve",
                      style: TextStyle(color: colorSet.mainGold),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      await _updateImageStatusWithDescription(id, newStatus, "");

      // Cari CustomImageInfo dengan id yang sesuai
      CustomImageInfo? selectedImage;
      for (var imageInfo in snapshot) {
        if (imageInfo.id == id) {
          selectedImage = imageInfo;
          break;
        }
      }

      // Cetak informasi gambar yang diperbarui
      if (selectedImage != null) {
        print('Updated status of image ${selectedImage.id} to $newStatus');
        await saveDataToSharedPreferences(selectedImage, newStatus);
      }

      if (onSubmit != null) onSubmit();
    }
  }

  Future<void> _updateImageStatusWithDescription(
      String id, String newStatus, String deskripsi) async {
    final response = await http.post(
      Uri.parse(
          // 'https://menuku.id/flutter/validasifoto/update_status_nota_FileFixer.php'),
          // 'https://api.verification.lifetimedesign.id/dummy_update_status_nota_FileFixer.php'),

          'https://api.verification.lifetimedesign.id/update_status_nota_FileFixer.php'),
      body: {
        'id': id,
        'status': newStatus,
        'deskripsi_status': deskripsi,
      },
    );

    if (response.statusCode == 200) {
      // Navigator.pop(context);
      // Navigator.pop(context);
      print('Status updated successfully');
      // Setelah berhasil memperbarui status gambar, dapatkan nilai userId dari tabel validasi
      try {
        final userIdResponse = await http.post(
          Uri.parse(
              // 'https://menuku.id/flutter/validasifoto/App_File_Fixer/get_userid_from_validasi.php'),

              'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_userid_from_validasi.php'),
          body: {
            'id': id,
          },
        );
        if (userIdResponse.statusCode == 200) {
          _refreshImages();
          final userId = jsonDecode(userIdResponse.body)['userId'] as int?;
          if (userId != null) {
            if (newStatus != 'Waiting')
              // Jika userId berhasil ditemukan, panggil fungsi untuk mendapatkan username dan fcmToken
              await getUserInfoAndSendNotification(
                  userId, newStatus, deskripsi);
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

  Future<void> getUserInfoAndSendNotification(
      int userId, String newStatus, String deskripsiImage) async {
    try {
      final userInfoResponse = await http.post(
        Uri.parse(
            // 'https://menuku.id/flutter/validasifoto/App_File_Fixer/get_user_info.php'),
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
          await sendNotification(username, fcmToken, companyName!, status!,
              newStatus, deskripsiImage);
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
          images = images
              .where((image) => image.statusIMG == selectedValue)
              .toList();
        }
        return Future.value(images);
      });
    });
  }

  // void _handleFilterSelection(String? selectedValue) {
  //   setState(() {
  //     if (selectedValue == 'Approved') {
  //       // Fetch all images with status 'Approved'
  //       _futureImages = fetchImages().then((images) {
  //         // Sort the images by upload date
  //         images.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
  //         // Take the latest 15 images
  //         final latestApprovedImages = images.take(30).toList();
  //         return Future.value(latestApprovedImages);
  //       });
  //     } else {
  //       // For other filter values, fetch all images
  //       _futureImages = fetchImages();
  //     }
  //   });
  // }

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
              image.companyName.toLowerCase().contains(query.toLowerCase()) ||
              image.id.toString().toLowerCase().contains(query.toLowerCase()) ||
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

  // Future<void> _selectDateRange(BuildContext context) async {
  //   final DateTimeRange? picked = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(9999),
  //     initialDateRange: DateTimeRange(
  //       start: _selectedStartDate,
  //       end: _selectedEndDate,
  //     ),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _selectedStartDate = picked.start;
  //       _selectedEndDate = picked.end;
  //     });
  //     _filterByDateRange(picked.start, picked.end);
  //   }
  // }

  void _selectDateRange(BuildContext context) async {
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

        // Simpan rentang tanggal terpilih terakhir
        _defaultStartDate = picked.start;
        _defaultEndDate = picked.end;
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
          icon: Icon(
            Icons.search,
            color: colorSet.mainBG,
          ),
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

  List<CustomImageInfo> _filteredList(List<CustomImageInfo>? data) {
    if (data == null || data.isEmpty) {
      return [];
    } else {
      return data.where((imageInfo) {
        final uploadDate = DateTime.parse(imageInfo.tanggal_upload_hari_ini);
        final matchesSearch = _searchText.isEmpty ||
            imageInfo.tanggal_upload_hari_ini
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            imageInfo.companyName
                .toLowerCase()
                .contains(_searchText.toLowerCase());
        final withinDateRange = uploadDate.isAfter(
                _selectedStartDate.subtract(const Duration(days: 1))) &&
            uploadDate.isBefore(_selectedEndDate.add(const Duration(days: 1)));
        return matchesSearch && withinDateRange;
      }).toList();
    }
  }

  Future<void> _deleteImage(CustomImageInfo imageInfo) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/delete_image.php'),
        body: {
          'id': imageInfo.id.toString(),
        },
      );
      if (response.statusCode == 200) {
        print('Image deleted successfully');
        // Tampilkan Snackbar untuk memberi tahu pengguna bahwa gambar telah dihapus
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image deleted successfully'),
            backgroundColor: Colors.green, // Atur warna latar belakang Snackbar
          ),
        );
        // Setelah gambar dihapus, Anda mungkin perlu memperbarui daftar gambar dengan memanggil fungsi _refreshImages
        _refreshImages();
      } else {
        print('Failed to delete image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, CustomImageInfo imageInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorSet.mainGold,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colorSet.listTile2, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text("Delete Image"),
          content: Text("Are you sure you want to delete this image?"),
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
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: colorSet.mainBG),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Panggil fungsi untuk menghapus gambar
                _deleteImage(imageInfo);
                Navigator.of(context).pop(); // Tutup dialog
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

  Future<void> updateStatusReadAdmin(String imageId) async {
    // Buat permintaan HTTP untuk memperbarui statusReadAdmin menjadi "true"
    final url = Uri.parse(
        // 'https://menuku.id/flutter/validasifoto/App_File_Fixer/update_status_read.php');
        // 'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/dummy_update_status_read.php');

        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_status_read.php');
    final response = await http.post(
      url,
      body: {
        'statusReadAdmin': 'false',
        'imageId': imageId,
      },
    );

    // Periksa respons
    if (response.statusCode == 200) {
      print('StatusReadAdmin updated successfully');
    } else {
      print('Failed to update StatusReadAdmin');
    }
  }

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

                    var isDropdownEnabled = status == 'procurement' &&
                            imageInfo.statusReadAdmin != 'read false status' ||
                        status == 'super admin';

                    return GestureDetector(
                      // onLongPress: () {
                      //   if (status != 'procurement' && status != 'vendor')
                      //     [_showDeleteConfirmationDialog(context, imageInfo)];
                      // },

                      onLongPress: () {
                        // Jika pengguna bukan procurement atau vendor, dan status gambar bukan 'Approved'
                        if ((status != 'procurement' && status != 'vendor') &&
                            imageInfo.statusIMG != 'Approved') {
                          _showDeleteConfirmationDialog(context, imageInfo);
                        }
                      },
                      onTap: () {
                        // Arahkan ke DetailPage dengan data CustomImageInfo
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailPageSPA(imageInfo: imageInfo),
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
                                                // 'https://menuku.id/flutter/validasifoto/${imageInfo.filePath}',

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
                                            // 'https://menuku.id/flutter/validasifoto/${imageInfo.filePath}',

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
                                          Text('Upload'),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 1.3),
                                            child: Text('   :  '),
                                          ),
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
                                    color: getColorBasedOnStatus(
                                            imageInfo.statusIMG)
                                        .withOpacity(0.3),
                                    border: Border.all(
                                      color: getColorBasedOnStatus(
                                          imageInfo.statusIMG),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: (imageInfo.statusReadAdmin ==
                                                      'read false status' ||
                                                  imageInfo.statusReadAdmin ==
                                                      'unread') &&
                                              status != 'super admin'
                                          ? Center(
                                              child: Text(
                                                imageInfo.statusIMG,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorSet.mainBG,
                                                ),
                                              ),
                                            )
                                          : DropdownButton<String>(
                                              value: imageInfo.statusIMG,
                                              onChanged: (newValue) {
                                                if (imageInfo.statusIMG ==
                                                        'Approved' ||
                                                    (status == 'procurement' &&
                                                        status ==
                                                            'super admin' &&
                                                        imageInfo
                                                            .hasChangedStatus)) {
                                                  return;
                                                }
                                                if (newValue == 'Rejected') {
                                                  updateImageStatus(
                                                      imageInfo.id,
                                                      newValue!,
                                                      snapshot.data!,
                                                      onSubmit: () {
                                                    setState(() {
                                                      updateStatusReadAdmin(
                                                          imageInfo.id);
                                                      imageInfo.statusIMG =
                                                          newValue;
                                                    });
                                                  });
                                                  Navigator.pop(context);
                                                }
                                                if (newValue == 'Approved') {
                                                  updateImageStatus(
                                                      imageInfo.id,
                                                      newValue!,
                                                      snapshot.data!,
                                                      onSubmit: () {
                                                    setState(() {
                                                      updateStatusReadAdmin(
                                                          imageInfo.id);
                                                      imageInfo.statusIMG =
                                                          newValue;
                                                      if (status ==
                                                          'procurement') {
                                                        isDropdownEnabled =
                                                            false;
                                                      }
                                                    });
                                                  });
                                                } else {
                                                  updateImageStatus(
                                                    imageInfo.id,
                                                    newValue!,
                                                    snapshot.data!,
                                                  );
                                                  // updateStatusReadAdmin(
                                                  //     imageInfo.id);
                                                  // setState(() {
                                                  //   if (status ==
                                                  //       'procurement') {
                                                  //     updateStatusReadAdmin(
                                                  //         imageInfo.id);
                                                  //   }
                                                  //   imageInfo.status = newValue;
                                                  // });
                                                }
                                              },
                                              items: <String>[
                                                'Waiting',
                                                'Approved',
                                                'Rejected'
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: colorSet.mainBG,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              underline: SizedBox.shrink(),
                                              isExpanded: true,
                                              icon:
                                                  null, // Remove the arrow icon
                                            )),
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

  String formatDateYear(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy').format(parsedDate);
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
