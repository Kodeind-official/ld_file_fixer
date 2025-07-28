import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import '/UI/detail_foto.dart';
import '/Vendor2/home.dart';
import '/super_admin/detail2.dart';
import '/utility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final CustomImageInfo imageInfo;

  DetailPage({required this.imageInfo});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String? username;
  String? status;
  String? lokasi;
  int? userId;
  List<CustomImageInfo> matchedData = [];
  bool isLoading = false;
  List<Map<String, dynamic>> comparisonResults = [];
  double totalSimilarityPercentage = 0;
  String _recognizedText = '';
  String _secondRecognizedText = '';

  String _textureInfo = '';
  String _lineInfo = '';
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      username = prefs.getString('username');
      status = prefs.getString('status');
      lokasi = prefs.getString('lokasi');
    });

    // Perbarui statusReadVendor atau statusReadAdmin
    if (status == 'vendor') {
      // Ubah statusReadVendor menjadi "true"
      await updateStatusReadVendor(widget.imageInfo.id);
    } else if (status == 'super admin' || status == 'procurement') {
      // Ubah statusReadAdmin menjadi "true"
      await updateStatusReadAdmin(widget.imageInfo.id);
    }
  }

  Future<void> updateStatusReadVendor(String imageId) async {
    // Buat permintaan HTTP untuk memperbarui statusReadVendor menjadi "true"
    final url = Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_status_read.php');
    final response = await http.post(
      url,
      body: {
        'statusReadVendor': 'true',
        'imageId': imageId,
      },
    );

    // Periksa respons
    if (response.statusCode == 200) {
      print('StatusReadVendor updated successfully');
    } else {
      print('Failed to update StatusReadVendor');
    }
  }

  Future<void> updateStatusReadAdmin(String imageId) async {
    // Buat permintaan HTTP untuk memperbarui statusReadAdmin menjadi "true"
    final url = Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_status_read.php');
    final response = await http.post(
      url,
      body: {
        'statusReadAdmin': 'true',
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
  Future<bool> _onWillPop() async {
   Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      HomePageVendor2()),
             (Route<dynamic> route) => false);
    return false; // Return 'false' untuk mencegah aksi pop default (opsional).
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: colorSet.pewter,
          
          appBar: AppBar(
            centerTitle: true,
            iconTheme: IconThemeData(
              color: colorSet.mainBG,
            ),
            forceMaterialTransparency: true,
            backgroundColor: Colors.transparent,
            title: Text(
              '${widget.imageInfo.companyName}',
              style: ThisTextStyle.bold22MainBg,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tampilkan informasi dari objek CustomImageInfo
                // Text(
                //   '${widget.imageInfo.companyName}',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: colorSet.mainGold),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blueGrey,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImagePage(
                                imageUrls: [
                                  'https://api.verification.lifetimedesign.id/${widget.imageInfo.filePath}',
                                ],
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          'https://api.verification.lifetimedesign.id/${widget.imageInfo.filePath}',
                          fit: BoxFit.cover,
                          height: 370,
                          width: double.infinity,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color:
                                  Colors.grey, // Warna latar belakang kontainer
                              child: Center(
                                child: Text(
                                  'Waiting', // Pesan atau konten alternatif yang ingin ditampilkan saat terjadi kesalahan
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('NOTA', style: ThisTextStyle.bold14MainGold),
                      // Text(
                      //     formatDateYear(
                      //         widget.imageInfo.tanggal_upload_hari_ini),
                      //     style: ThisTextStyle.bold14MainGold),
                      Text('${"-" + widget.imageInfo.id}',
                          style: ThisTextStyle.bold14MainGold),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Container(
                      padding:
                          const EdgeInsets.only(left: 25, right: 15, top: 12),
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorSet.listTile1,
                        borderRadius:
                            BorderRadius.circular(15), // Tambahkan radius
                      ),
                      child: Text(
                          'Upload Date   :   ${formatDate(widget.imageInfo.tanggal_upload_hari_ini)}')),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Container(
                      padding:
                          const EdgeInsets.only(left: 25, right: 15, top: 12),
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorSet.listTile1,
                        borderRadius:
                            BorderRadius.circular(15), // Tambahkan radius
                      ),
                      child: Text(
                          'Total Price      :   Rp.${widget.imageInfo.deskripsi}')),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 25, right: 15, top: 12),
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorSet.listTile1,
                      borderRadius:
                          BorderRadius.circular(15), // Tambahkan radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        child: Row(
                          children: [
                            Text('Status              :    '),
                            Text(
                              widget.imageInfo
                                  .statusIMG, // Tampilkan status saat ini
                              style: TextStyle(
                                  fontSize: 14, color: colorSet.mainGold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Container(
                      padding: const EdgeInsets.only(
                          left: 25, right: 15, top: 25, bottom: 35),
                      // height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorSet.listTile1,
                        borderRadius:
                            BorderRadius.circular(15), // Tambahkan radius
                      ),
                      child: Text(
                          'Description      :  ${widget.imageInfo.deskripsi_status}')),
                ),

                // Tampilkan gambar dari URL

                // SizedBox(height: 16),
                // Tombol cek

                SizedBox(height: 16),
                isEmpty && !isLoading) Text('No Result'),
              ],
            ),
          ),
        ));
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM yyyy').format(parsedDate);
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
          'body': 'Lihat Pengajuan...!',
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
                    labelText: "Deskripsi",
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
          'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/update_status.php'),
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
}

class ComparisonResult {
  final String ocrResult1;
  final String ocrResult2;
  final double similarityPercentage;

  ComparisonResult({
    required this.ocrResult1,
    required this.ocrResult2,
    required this.similarityPercentage,
  });
}
