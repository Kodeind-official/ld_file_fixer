import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '/UI/splashScreenPage.dart';
import '/Vendor2/detail2.dart';
import '/firebase_options.dart';
import '/super_admin/detail2.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences package

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

void main() async {

  var bytes = utf8.encode("data yang akan di-hash"); 
  var digest = sha256.convert(bytes);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Pemantau peristiwa untuk pesan FCM yang diterima
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Pesan FCM diterima: ${message.data}");
    // Di sini Anda dapat menambahkan logika untuk menangani pesan FCM
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Pesan FCM diterima saat aplikasi sedang berjalan: ${message.data}");
    // Di sini Anda dapat menambahkan logika untuk menangani pesan notifikasi
  });

  // Pemantau peristiwa untuk notifikasi yang di klik dan aplikasi terbuka
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notifikasi di klik ketika aplikasi terbuka!');
    _handleNotificationClick(message);
  });

  // Dapatkan FCM token pengguna dan cetak ke terminal
  String? fcmToken = await messaging.getToken();
  print("FCM Token: $fcmToken");

  // Pemantau peristiwa untuk perubahan token
  messaging.onTokenRefresh.listen((String? newToken) {
    print("Token FCM diperbarui: $newToken");
    // Di sini Anda dapat menambahkan logika untuk menangani perubahan token
  });

  // Periksa apakah aplikasi dibuka dari notifikasi
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  runApp(MyApp(initialMessage: initialMessage));
}

void _handleNotificationClick(RemoteMessage message) async {
  // Ambil data yang diperlukan untuk menavigasi ke halaman DetailPage
  final imageId = message.data['image_id'] as String?;
  final userId = message.data['user_id'] as String?;
  final filePath = message.data['file_path'] as String?;
  final uploadDateOri = message.data['upload_date_ori'] as String?;
  final uploadDate = message.data['upload_date'] as String?;
  final uploadDate2 = message.data['upload_date_2'] as String?;
  final companyName = message.data['company_name'] as String?;
  final status = message.data['status'] as String?;
  final username = message.data['username'] as String?;
  final description = message.data['description'] as String?;
  final statusReadVendor = message.data['status_read_vendor'] as String?;
  final statusReadAdmin = message.data['status_read_admin'] as String?;
  final tanggal_upload_hari_ini =
      message.data['tanggal_upload_hari_ini'] as String?;
  final description_status = message.data['description_status'] as String?;

  final prefs = await SharedPreferences.getInstance();
  final userStatus = prefs.getString('status');

  // Cek apakah nilai yang diperoleh dari message.data null
  if (imageId != null &&
      userId != null &&
      filePath != null &&
      uploadDateOri != null &&
      uploadDate != null &&
      uploadDate2 != null &&
      companyName != null &&
      status != null &&
      username != null &&
      description != null &&
      statusReadVendor != null &&
      statusReadAdmin != null &&
      tanggal_upload_hari_ini != null &&
      description_status != null) {
    // Navigasi ke halaman DetailPage atau DetailPageSPA berdasarkan status pengguna
    if (userStatus != null && userStatus != "vendor") {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => DetailPageSPA(
            imageInfo: CustomImageInfo(
              id: imageId,
              userIdLogin: userId,
              filePath: filePath,
              uploadDateOri: uploadDateOri,
              uploadDate: uploadDate,
              uploadDate2: uploadDate2,
              companyName: companyName,
              statusIMG: status,
              username: username,
              deskripsi: description,
              statusReadVendor: statusReadVendor,
              statusReadAdmin: statusReadAdmin,
              tanggal_upload_hari_ini: tanggal_upload_hari_ini,
              deskripsi_status: description_status,
            ),
          ),
        ),
      );
    } else {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => DetailPage(
            imageInfo: CustomImageInfo(
              id: imageId,
              userIdLogin: userId,
              filePath: filePath,
              uploadDateOri: uploadDateOri,
              uploadDate: uploadDate,
              uploadDate2: uploadDate2,
              companyName: companyName,
              statusIMG: status,
              username: username,
              deskripsi: description,
              statusReadVendor: statusReadVendor,
              statusReadAdmin: statusReadAdmin,
              tanggal_upload_hari_ini: tanggal_upload_hari_ini,
              deskripsi_status: description_status,
            ),
          ),
        ),
      );
    }
  } else {
    // Handle null values or show an error message
    print('One or more values retrieved from message.data are null.');
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final RemoteMessage? initialMessage;

  MyApp({this.initialMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialMessage == null
          ? SplashScreenPage()
          : DetailPageFromMessage(message: initialMessage),
      navigatorKey: navigatorKey,
    );
  }
}

class DetailPageFromMessage extends StatelessWidget {
  final RemoteMessage? message;

  DetailPageFromMessage({this.message});

  @override
  Widget build(BuildContext context) {
    if (message != null) {
      // Ambil data dari message.data dan buat DetailPage
      final imageId = message!.data['image_id'] as String?;
      final userId = message!.data['user_id'] as String?;
      final filePath = message!.data['file_path'] as String?;
      final uploadDateOri = message!.data['upload_date_ori'] as String?;
      final uploadDate = message!.data['upload_date'] as String?;
      final uploadDate2 = message!.data['upload_date_2'] as String?;
      final companyName = message!.data['company_name'] as String?;
      final status = message!.data['status'] as String?;
      final username = message!.data['username'] as String?;
      final description = message!.data['description'] as String?;
      final statusReadVendor = message!.data['status_read_vendor'] as String?;
      final statusReadAdmin = message!.data['status_read_admin'] as String?;
      final tanggal_upload_hari_ini =
          message!.data['tanggal_upload_hari_ini'] as String?;
      final description_status = message!.data['description_status'] as String?;

      return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading preferences'));
          } else {
            final prefs = snapshot.data!;
            final userStatus = prefs.getString('status');

            if (imageId != null &&
                userId != null &&
                filePath != null &&
                uploadDateOri != null &&
                uploadDate != null &&
                uploadDate2 != null &&
                companyName != null &&
                status != null &&
                username != null &&
                description != null &&
                statusReadVendor != null &&
                statusReadAdmin != null &&
                tanggal_upload_hari_ini != null &&
                description_status != null) {
              if (userStatus != null && userStatus != "vendor") {
                return DetailPageSPA(
                  imageInfo: CustomImageInfo(
                    id: imageId,
                    userIdLogin: userId,
                    filePath: filePath,
                    uploadDateOri: uploadDateOri,
                    uploadDate: uploadDate,
                    uploadDate2: uploadDate2,
                    companyName: companyName,
                    statusIMG: status,
                    username: username,
                    deskripsi: description,
                    statusReadVendor: statusReadVendor,
                    statusReadAdmin: statusReadAdmin,
                    tanggal_upload_hari_ini: tanggal_upload_hari_ini,
                    deskripsi_status: description_status,
                  ),
                );
              } else {
                return DetailPage(
                  imageInfo: CustomImageInfo(
                    id: imageId,
                    userIdLogin: userId,
                    filePath: filePath,
                    uploadDateOri: uploadDateOri,
                    uploadDate: uploadDate,
                    uploadDate2: uploadDate2,
                    companyName: companyName,
                    statusIMG: status,
                    username: username,
                    deskripsi: description,
                    statusReadVendor: statusReadVendor,
                    statusReadAdmin: statusReadAdmin,
                    tanggal_upload_hari_ini: tanggal_upload_hari_ini,
                    deskripsi_status: description_status,
                  ),
                );
              }
            } else {
              return SplashScreenPage();
            }
          }
        },
      );
    } else {
      return SplashScreenPage();
    }
  }
}

class TemporaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(''),
      ),
    );
  }
}