// // import 'package:bismillahnota/with_tesseract.dart';
// import 'dart:convert';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '/UI/splashScreenPage.dart';
// import '/firebase_options.dart';
// import '/super_admin/detail2.dart';

// FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Workmanager().initialize(callbackDispatcher);
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Pemantau peristiwa untuk pesan FCM yang diterima
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("Pesan FCM diterima: ${message.data}");
//     // Di sini Anda dapat menambahkan logika untuk menangani pesan FCM
//   });

//   // Dapatkan FCM token pengguna dan cetak ke terminal
//   String? fcmToken = await messaging.getToken();
//   print("FCM Token: $fcmToken");

//   // Pemantau peristiwa untuk perubahan token
//   messaging.onTokenRefresh.listen((String? newToken) {
//     print("Token FCM diperbarui: $newToken");
//     // Di sini Anda dapat menambahkan logika untuk menangani perubahan token
//   });
//   ;
//   runApp(MyApp());
// }

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import '/Vendor2/detail2.dart';
// import '/firebase_options.dart';
// import '/UI/splashScreenPage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Pemantau peristiwa untuk pesan FCM yang diterima
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("Pesan FCM diterima: ${message.data}");
//     // Di sini Anda dapat menambahkan logika untuk menangani pesan FCM
//   });
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   print("Pesan FCM diterima saat aplikasi sedang berjalan: ${message.data}");
//   // Di sini Anda dapat menambahkan logika untuk menangani pesan notifikasi
// });

//   // Pemantau peristiwa untuk notifikasi yang di klik dan aplikasi terbuka
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('Notifikasi di klik ketika aplikasi terbuka!');
//     _handleNotificationClick(message);
//   });

//   // Dapatkan FCM token pengguna dan cetak ke terminal
//   String? fcmToken = await messaging.getToken();
//   print("FCM Token: $fcmToken");

//   // Pemantau peristiwa untuk perubahan token
//   messaging.onTokenRefresh.listen((String? newToken) {
//     print("Token FCM diperbarui: $newToken");
//     // Di sini Anda dapat menambahkan logika untuk menangani perubahan token
//   });

//   runApp(MyApp());
// }

// void _handleNotificationClick(RemoteMessage message) {
//   // Ambil data yang diperlukan untuk menavigasi ke halaman DetailPage
//   final imageId = message.data['image_id'] as String?;
//   final userId = message.data['user_id'] as String?;
//   final filePath = message.data['file_path'] as String?;
//   final uploadDateOri = message.data['upload_date_ori'] as String?;
//   final uploadDate = message.data['upload_date'] as String?;
//   final uploadDate2 = message.data['upload_date_2'] as String?;
//   final companyName = message.data['company_name'] as String?;
//   final status = message.data['status'] as String?;
//   final username = message.data['username'] as String?;
//   final description = message.data['description'] as String?;
//   final statusReadVendor = message.data['status_read_vendor'] as String?;
//   final statusReadAdmin = message.data['status_read_admin'] as String?;
//   final tanggal_upload_hari_ini = message.data['tanggal_upload_hari_ini'] as String?;
//   final description_status = message.data['description_status'] as String?;

//   // Cek apakah nilai yang diperoleh dari message.data null
//   if (imageId != null &&
//       userId != null &&
//       filePath != null &&
//       uploadDateOri != null &&
//       uploadDate != null &&
//       uploadDate2 != null &&
//       companyName != null &&
//       status != null &&
//       username != null &&
//       description != null &&
//       statusReadVendor != null &&
//       statusReadAdmin != null &&
//       tanggal_upload_hari_ini != null &&
//       description_status != null) {
//     // Navigasi ke halaman DetailPage dengan data yang diperlukan
//     navigatorKey.currentState!.push(
//       MaterialPageRoute(
//         builder: (context) => DetailPage(
//           imageInfo: CustomImageInfo(
//             id: imageId,
//             userIdLogin: userId,
//             filePath: filePath,
//             uploadDateOri: uploadDateOri,
//             uploadDate: uploadDate,
//             uploadDate2: uploadDate2,
//             companyName: companyName,
//             statusIMG: status,
//             username: username,
//             deskripsi: description,
//             statusReadVendor: statusReadVendor,
//             statusReadAdmin: statusReadAdmin,
//             tanggal_upload_hari_ini: tanggal_upload_hari_ini,
//             deskripsi_status: description_status,
//           ),
//         ),
//       ),
//     );
//   } else {
//     // Handle null values or show an error message
//     print('One or more values retrieved from message.data are null.');
//   }
// }

// GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SplashScreenPage(),
//       navigatorKey: navigatorKey,
//     );
//   }
// }

// pake ini

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import '/Vendor2/detail2.dart';
// import '/firebase_options.dart';
// import '/UI/splashScreenPage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Pemantau peristiwa untuk pesan FCM yang diterima
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("Pesan FCM diterima: ${message.data}");
//     // Di sini Anda dapat menambahkan logika untuk menangani pesan FCM
//   });

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("Pesan FCM diterima saat aplikasi sedang berjalan: ${message.data}");
//     // Di sini Anda dapat menambahkan logika untuk menangani pesan notifikasi
//   });

//   // Pemantau peristiwa untuk notifikasi yang di klik dan aplikasi terbuka
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('Notifikasi di klik ketika aplikasi terbuka!');
//     _handleNotificationClick(message);
//   });

//   // Dapatkan FCM token pengguna dan cetak ke terminal
//   String? fcmToken = await messaging.getToken();
//   print("FCM Token: $fcmToken");

//   // Pemantau peristiwa untuk perubahan token
//   messaging.onTokenRefresh.listen((String? newToken) {
//     print("Token FCM diperbarui: $newToken");
//     // Di sini Anda dapat menambahkan logika untuk menangani perubahan token
//   });

//   // Periksa apakah aplikasi dibuka dari notifikasi
//   RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//   runApp(MyApp(initialMessage: initialMessage));
// }

// void _handleNotificationClick(RemoteMessage message) {
//   // Ambil data yang diperlukan untuk menavigasi ke halaman DetailPage
//   final imageId = message.data['image_id'] as String?;
//   final userId = message.data['user_id'] as String?;
//   final filePath = message.data['file_path'] as String?;
//   final uploadDateOri = message.data['upload_date_ori'] as String?;
//   final uploadDate = message.data['upload_date'] as String?;
//   final uploadDate2 = message.data['upload_date_2'] as String?;
//   final companyName = message.data['company_name'] as String?;
//   final status = message.data['status'] as String?;
//   final username = message.data['username'] as String?;
//   final description = message.data['description'] as String?;
//   final statusReadVendor = message.data['status_read_vendor'] as String?;
//   final statusReadAdmin = message.data['status_read_admin'] as String?;
//   final tanggal_upload_hari_ini = message.data['tanggal_upload_hari_ini'] as String?;
//   final description_status = message.data['description_status'] as String?;

//   // Cek apakah nilai yang diperoleh dari message.data null
//   if (imageId != null &&
//       userId != null &&
//       filePath != null &&
//       uploadDateOri != null &&
//       uploadDate != null &&
//       uploadDate2 != null &&
//       companyName != null &&
//       status != null &&
//       username != null &&
//       description != null &&
//       statusReadVendor != null &&
//       statusReadAdmin != null &&
//       tanggal_upload_hari_ini != null &&
//       description_status != null) {
//     // Navigasi ke halaman DetailPage dengan data yang diperlukan
//     navigatorKey.currentState!.push(
//       MaterialPageRoute(
//         builder: (context) => DetailPage(
//           imageInfo: CustomImageInfo(
//             id: imageId,
//             userIdLogin: userId,
//             filePath: filePath,
//             uploadDateOri: uploadDateOri,
//             uploadDate: uploadDate,
//             uploadDate2: uploadDate2,
//             companyName: companyName,
//             statusIMG: status,
//             username: username,
//             deskripsi: description,
//             statusReadVendor: statusReadVendor,
//             statusReadAdmin: statusReadAdmin,
//             tanggal_upload_hari_ini: tanggal_upload_hari_ini,
//             deskripsi_status: description_status,
//           ),
//         ),
//       ),
//     );
//   } else {
//     // Handle null values or show an error message
//     print('One or more values retrieved from message.data are null.');
//   }
// }

// GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   final RemoteMessage? initialMessage;

//   MyApp({this.initialMessage});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: initialMessage == null ? SplashScreenPage() : DetailPageFromMessage(message: initialMessage),
//       navigatorKey: navigatorKey,
//     );
//   }
// }

// class DetailPageFromMessage extends StatelessWidget {
//   final RemoteMessage? message;

//   DetailPageFromMessage({this.message});

//   @override
//   Widget build(BuildContext context) {
//     if (message != null) {
//       // Ambil data dari message.data dan buat DetailPage
//       final imageId = message!.data['image_id'] as String?;
//       final userId = message!.data['user_id'] as String?;
//       final filePath = message!.data['file_path'] as String?;
//       final uploadDateOri = message!.data['upload_date_ori'] as String?;
//       final uploadDate = message!.data['upload_date'] as String?;
//       final uploadDate2 = message!.data['upload_date_2'] as String?;
//       final companyName = message!.data['company_name'] as String?;
//       final status = message!.data['status'] as String?;
//       final username = message!.data['username'] as String?;
//       final description = message!.data['description'] as String?;
//       final statusReadVendor = message!.data['status_read_vendor'] as String?;
//       final statusReadAdmin = message!.data['status_read_admin'] as String?;
//       final tanggal_upload_hari_ini = message!.data['tanggal_upload_hari_ini'] as String?;
//       final description_status = message!.data['description_status'] as String?;

//       // Cek apakah nilai yang diperoleh dari message.data null
//       if (imageId != null &&
//           userId != null &&
//           filePath != null &&
//           uploadDateOri != null &&
//           uploadDate != null &&
//           uploadDate2 != null &&
//           companyName != null &&
//           status != null &&
//           username != null &&
//           description != null &&
//           statusReadVendor != null &&
//           statusReadAdmin != null &&
//           tanggal_upload_hari_ini != null &&
//           description_status != null) {
//         // Return DetailPage dengan data yang diperlukan
//         return DetailPage(
//           imageInfo: CustomImageInfo(
//             id: imageId,
//             userIdLogin: userId,
//             filePath: filePath,
//             uploadDateOri: uploadDateOri,
//             uploadDate: uploadDate,
//             uploadDate2: uploadDate2,
//             companyName: companyName,
//             statusIMG: status,
//             username: username,
//             deskripsi: description,
//             statusReadVendor: statusReadVendor,
//             statusReadAdmin: statusReadAdmin,
//             tanggal_upload_hari_ini: tanggal_upload_hari_ini,
//             deskripsi_status: description_status,
//           ),
//         );
//       } else {
//         // Handle null values or show an error message
//         return Scaffold(
//           body: Center(child: Text('One or more values retrieved from message.data are null.')),
//         );
//       }
//     } else {
//       // Handle the case where message is null
//       return Scaffold(
//         body: Center(child: Text('No initial message found.')),
//       );
//     }
//   }
// }

// class CheckUserPage extends StatefulWidget {
//   @override
//   _CheckUserPageState createState() => _CheckUserPageState();
// }

// class _CheckUserPageState extends State<CheckUserPage> {
//   @override
//   void initState() {
//     super.initState();
//     _checkUser();
//   }

//   Future<void> _checkUser() async {
//     final response = await http.get(Uri.parse('https://menuku.id/flutter/validasifoto/testing.php'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['exists'] == true) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SplashScreenPage()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => TemporaryPage()),
//         );
//       }
//     } else {
//       // Handle server error
//       print('Failed to check user');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }

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



// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:image/image.dart' as img;
// import 'dart:math';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   File? _image;
//   String _recognizedText = '';
//   String _textureInfo = '';

//   final picker = ImagePicker();

//   Future<void> _getImageFromGallery() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//       _processImageAndRecognizeText(_image!);
//     }
//   }

//   Future<void> _processImageAndRecognizeText(File image) async {
//     final inputImage = img.decodeImage(image.readAsBytesSync());

//     if (inputImage == null) {
//       setState(() {
//         _recognizedText = 'Error processing image';
//         _textureInfo = 'Error processing image';
//       });
//       return;
//     }

//     // Convert to grayscale
//     final grayscaleImage = img.grayscale(inputImage);

//     // Apply Gaussian blur to reduce noise
//     final blurredImage = img.gaussianBlur(grayscaleImage, 1);

//     // Analyze texture using Gabor filter
//     final textureImage = _applyGaborFilter(blurredImage);

//     // Analyze histogram
//     final histogram = _computeHistogram(grayscaleImage);

//     // Prepare for OCR
//     final inputImageForOCR = InputImage.fromFile(File(image.path));
//     final textRecognizer = GoogleMlKit.vision.textRecognizer();
//     final RecognizedText recognizedText = await textRecognizer.processImage(inputImageForOCR);

//     setState(() {
//       _recognizedText = recognizedText.text;
//       _textureInfo = 'Texture features and histogram calculated.';
//     });

//     await textRecognizer.close();
//   }

//   img.Image _applyGaborFilter(img.Image image) {
//     final output = img.Image(image.width, image.height);
//     // Apply Gabor filter (simple example, you might want to adjust parameters or use a library for a robust implementation)
//     for (int y = 0; y < image.height; y++) {
//       for (int x = 0; x < image.width; x++) {
//         final pixel = image.getPixel(x, y);
//         final luma = img.getLuminance(pixel);
//         final gabor = (sin(2 * pi * luma / 256) + 1) / 2 * 255;  // Simple Gabor filter
//         output.setPixel(x, y, img.getColor(gabor.toInt(), gabor.toInt(), gabor.toInt()));
//       }
//     }
//     return output;
//   }

//   List<int> _computeHistogram(img.Image image) {
//     final histogram = List<int>.filled(256, 0);
//     for (int y = 0; y < image.height; y++) {
//       for (int x = 0; x < image.width; x++) {
//         final pixel = image.getPixel(x, y);
//         final luma = img.getLuminance(pixel);
//         histogram[luma]++;
//       }
//     }
//     return histogram;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Processing App'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               _image == null
//                   ? Text('No image selected.')
//                   : Image.file(_image!),
//               SizedBox(height: 16),
//               Text(
//                 _recognizedText,
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               Text(
//                 _textureInfo,
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _getImageFromGallery,
//         tooltip: 'Pick Image',
//         child: Icon(Icons.add_a_photo),
//       ),
//     );
//   }
// }
