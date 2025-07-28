import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '/UI/detail_foto.dart';
import '/super_admin/home.dart';
import '/utility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadImageSPAPage extends StatefulWidget {
  @override
  _UploadImageSPAPageState createState() => _UploadImageSPAPageState();
}

class _UploadImageSPAPageState extends State<UploadImageSPAPage> {
  String? username;
  String? status;
  String? deskripsi_status;
  String? lokasi;
  String? companyName;
  int? userId;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    fetchCompanyNames();
    _isMounted = true;
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Membaca informasi login dari SharedPreferences
      userId = prefs.getInt('userId');
      username = prefs.getString('username');
      status = prefs.getString('status');
      lokasi = prefs.getString('lokasi');
      companyName = prefs.getString('companyName');
    });

    print(userId);
  }

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<DateTime?> _selectedDates = [];
  // List<String?> _selectedLocations = [];
  List<String?> _selectedCompanyNames = [];
  List<String?> _descriptions = [];
  bool _isUploading = false;
  List<TextEditingController> _controllers = [];

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  List<String> _locations = [];
  // ignore: unused_field
  bool _canUploadImages = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _isMounted = false;
    super.dispose();
  }

  Future<void> fetchCompanyNames() async {
    final response = await http.get(Uri.parse(
        'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_dropdown.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<String> locations = data.cast<String>();
      setState(() {
        _locations = locations;
      });
    } else {
      throw Exception('Failed to load company names');
    }
  }

  final ImageLabeler _imageLabeler =
      ImageLabeler(options: ImageLabelerOptions());

  Future<void> _processImageLabel(XFile image, int imageNumber) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final labels = await _imageLabeler.processImage(inputImage);

    final allowedLabels = ["paper", "poster", "hand"];
    final disallowedLabels = [
      "eyelash",
      "car",
      "bicycle",
      "cup",
      "bottle",
      "food",
      "cat",
      "dog",
      "bird",
      "fish",
      "person",
      "child",
      "woman",
      "man",
      "nails",
      "hand",
    ];

    bool hasAllowedLabel = labels
        .any((label) => allowedLabels.contains(label.label.toLowerCase()));
    bool hasDisallowedLabel = labels
        .any((label) => disallowedLabels.contains(label.label.toLowerCase()));

    if (!hasAllowedLabel || hasDisallowedLabel) {
      print('Image $imageNumber tidak sesuai dengan aturan.');
      Navigator.pop(context);
      // setState(() {
      //   // Menghapus gambar yang tidak valid dari daftar _selectedImages
      //   _selectedImages.removeWhere((selectedImage) => selectedImage.path == image.path);

      //   // Menghapus data terkait dari daftar lainnya jika indeks valid
      //   if (imageNumber - 1 < _selectedDates.length) {
      //     _selectedDates.removeAt(imageNumber - 1);
      //   }
      //   if (imageNumber - 1 < _selectedCompanyNames.length) {
      //     _selectedCompanyNames.removeAt(imageNumber - 1);
      //   }
      //   if (imageNumber - 1 < _descriptions.length) {
      //     _descriptions.removeAt(imageNumber - 1);
      //   }
      //   if (imageNumber - 1 < _controllers.length) {
      //     _controllers[imageNumber - 1].dispose();
      //     _controllers.removeAt(imageNumber - 1);
      //   }
      // });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ALERT...!', style: TextStyle(color: Colors.white)),
            content: Text(
                "Gambar yang dipilih tidak sesuai. Silakan pilih gambar lain.",
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
            backgroundColor: colorSet.mainBG,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colorSet.mainGold, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      );
    }
  }

  void _initializeControllers(int length) {
    _controllers = List.generate(length, (index) => TextEditingController());
  }

  // Future<void> _pickImages(String source) async {
  //   XFile? pickedImage;

  //   if (source == 'camera') {
  //     // Ambil gambar dari kamera
  //     pickedImage = await _picker.pickImage(source: ImageSource.camera);

  //     if (pickedImage != null) {
  //       // Memotong gambar yang diambil
  //       final croppedImage = await _cropAndCompressImage(pickedImage);
  //       if (croppedImage != null) {
  //         // Tambahkan gambar yang dipotong ke daftar _selectedImages
  //         setState(() {
  //           _selectedImages.add(croppedImage);
  //           _initializeControllers(_selectedImages.length);
  //           _selectedDates.add(null);
  //           _selectedCompanyNames.add(null);
  //           _descriptions.add(null);

  //           // Proses gambar yang dipilih
  //           _processImageLabel(croppedImage, _selectedImages.length);

  //           // Atur kondisi validasi
  //           _canUploadImages = true;
  //         });
  //       }
  //     }
  //   } else if (source == 'gallery') {
  //     // Ambil gambar dari galeri
  //     List<XFile>? pickedImages = await _picker.pickMultiImage();

  //     // ignore: unnecessary_null_comparison
  //     if (pickedImages != null && pickedImages.isNotEmpty) {
  //       for (XFile image in pickedImages) {
  //         final croppedImage = await _cropAndCompressImage(image);
  //         if (croppedImage != null) {
  //           // Tambahkan gambar yang dipotong ke daftar _selectedImages
  //           setState(() {
  //             _selectedImages.add(croppedImage);
  //             _initializeControllers(_selectedImages.length);
  //             _selectedDates.add(null);
  //             _selectedCompanyNames.add(null);
  //             _descriptions.add(null);

  //             // Proses gambar yang dipilih
  //             _processImageLabel(croppedImage, _selectedImages.length);
  //           });
  //         }
  //       }
  //       // Atur kondisi validasi
  //       setState(() {
  //         _canUploadImages = true;
  //       });
  //     } else {
  //       _showSnackbar('Pilih maksimal 5 gambar.');
  //     }
  //   }
  //   // Informasi jumlah gambar yang dipilih
  //   print('Jumlah gambar yang dipilih: ${_selectedImages.length}');
  // }

//   Future<void> _pickImages(String source) async {
//     XFile? pickedImage;

//     if (source == 'camera') {
//       // Ambil gambar dari kamera
//       pickedImage = await _picker.pickImage(source: ImageSource.camera);

//       if (pickedImage != null) {
//         // Memotong gambar yang diambil
//         final croppedImage = await _cropAndCompressImage(pickedImage);
//         if (croppedImage != null) {
//           // Tambahkan gambar yang dipotong ke daftar _selectedImages
//           setState(() {
//             _selectedImages.add(croppedImage);
//             _initializeControllers(_selectedImages.length);
//             _selectedDates.add(null);
//             _selectedCompanyNames.add(null);
//             _descriptions.add(null);

//             // Proses gambar yang dipilih
//             _processImageLabel(croppedImage, _selectedImages.length);

//             // Atur kondisi validasi
//             _canUploadImages = true;
//           });
//         }
//       }
//     } else if (source == 'gallery') {
//       // Ambil gambar dari galeri
//       List<XFile>? pickedImages = await _picker.pickMultiImage();

//       // Pastikan tidak lebih dari 5 gambar yang dipilih
//       if (pickedImages != null && pickedImages.isNotEmpty) {
//         if (pickedImages.length > 5) {
//           _showSnackbar('Pilih maksimal 5 gambar.');
//         } else {
//           for (XFile image in pickedImages) {
//             final croppedImage = await _cropAndCompressImage(image);
//             if (croppedImage != null) {
//               // Tambahkan gambar yang dipotong ke daftar _selectedImages
//               setState(() {
//                 _selectedImages.add(croppedImage);
//                 _initializeControllers(_selectedImages.length);
//                 _selectedDates.add(null);
//                 _selectedCompanyNames.add(null);
//                 _descriptions.add(null);

//                 // Proses gambar yang dipilih
//                 _processImageLabel(croppedImage, _selectedImages.length);
//               });
//             }
//           }
//           // Atur kondisi validasi
//           setState(() {
//             _canUploadImages = true;
//           });
//         }
//       } else {
//         _showSnackbar('Pilih maksimal 5 gambar.');
//       }
//     }
//     // Informasi jumlah gambar yang dipilih
//     print('Jumlah gambar yang dipilih: ${_selectedImages.length}');
//   }

//   Future<XFile?> _cropAndCompressImage(XFile image) async {
//   final croppedFile = await ImageCropper().cropImage(
//     sourcePath: image.path,
//     aspectRatioPresets: [
//       CropAspectRatioPreset.original,
//       CropAspectRatioPreset.square,
//       CropAspectRatioPreset.ratio3x2,
//       CropAspectRatioPreset.ratio4x3,
//       CropAspectRatioPreset.ratio16x9,
//     ],
//     androidUiSettings: AndroidUiSettings(
//       toolbarTitle: 'Crop Image',
//       toolbarColor: colorSet.mainBG,
//       toolbarWidgetColor: Colors.white,
//       initAspectRatio: CropAspectRatioPreset.original,
//       lockAspectRatio: false,
//     ),
//     iosUiSettings: IOSUiSettings(
//       minimumAspectRatio: 1.0,
//     ),
//   );
//    showDialog(
//       context: context,
//       barrierDismissible: false, // Tidak bisa di-dismiss dengan mengetuk diluar dialog
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(width: 20),
//               Text("Processing image..."),
//             ],
//           ),
//         );
//       },
//     );
//   Navigator.pop(context);
//   showDialog(
//       context: context,
//       barrierDismissible: false, // Tidak bisa di-dismiss dengan mengetuk diluar dialog
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(width: 20),
//               Text("Processing image..."),
//             ],
//           ),
//         );
//       },
//     );

//   if (croppedFile != null) {

//     // Kompresi gambar yang dipotong
//     final compressedImage = await compressImage(File(croppedFile.path));

//     if (compressedImage != null) {
//       Navigator.pop(context); // Tutup dialog loading
//       return XFile(compressedImage.path);
//     }
//   }
//   return null;
// }

  Future<void> _pickImages(String source) async {
    XFile? pickedImage;

    if (source == 'camera') {
      // Ambil gambar dari kamera
      pickedImage = await _picker.pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        // Memotong gambar yang diambil
        final croppedImage = await _cropImage(pickedImage);
        if (croppedImage != null) {
          // Tambahkan gambar yang dipotong ke daftar _selectedImages
          setState(() {
            _selectedImages.add(croppedImage);
            _initializeControllers(_selectedImages.length);
            _selectedDates.add(null);
            _selectedCompanyNames.add(null);
            _descriptions.add(null);

            // Proses gambar yang dipilih
            _processImageLabel(croppedImage, _selectedImages.length);

            // Atur kondisi validasi
            _canUploadImages = true;
          });
        }
      }
    } else if (source == 'gallery') {
      // Ambil gambar dari galeri
      List<XFile>? pickedImages = await _picker.pickMultiImage();

      // Pastikan tidak lebih dari 5 gambar yang dipilih
      if (pickedImages != null && pickedImages.isNotEmpty) {
        if (pickedImages.length > 5) {
          _showSnackbar('Pilih maksimal 5 gambar.');
        } else {
          for (XFile image in pickedImages) {
            final croppedImage = await _cropImage(image);
            if (croppedImage != null) {
              // Tambahkan gambar yang dipotong ke daftar _selectedImages
              setState(() {
                _selectedImages.add(croppedImage);
                _initializeControllers(_selectedImages.length);
                _selectedDates.add(null);
                _selectedCompanyNames.add(null);
                _descriptions.add(null);

                // Proses gambar yang dipilih
                _processImageLabel(croppedImage, _selectedImages.length);
              });
            }
          }
          // Atur kondisi validasi
          setState(() {
            _canUploadImages = true;
          });
        }
      } else {
        _showSnackbar('Pilih maksimal 5 gambar.');
      }
    }
    // Informasi jumlah gambar yang dipilih
    print('Jumlah gambar yang dipilih: ${_selectedImages.length}');
  }

  Future<XFile?> _cropImage(XFile image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: colorSet.mainBG,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );

    if (croppedFile != null) {
      return XFile(croppedFile.path);
    }
    return null;
  }

  Future<File?> compressImage(File imageFile) async {
    try {
      // Baca gambar dari file
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      // Jika tidak bisa membaca gambar, return null
      if (image == null) return null;

      // Kompres gambar
      final compressedImage =
          img.encodeJpg(image, quality: 70); // Sesuaikan kualitas kompresi

      // Simpan gambar yang telah dikompres
      final tempDir = await getTemporaryDirectory();
      String newFileName = '.jpg';

      // Buat file baru dengan nama yang diinginkan
      final compressedFile = File('${tempDir.path}/$newFileName');
      await compressedFile.writeAsBytes(compressedImage);
      // final compressedFile = File(
      //   '${tempDir.path}/_${imageFile.uri.pathSegments.last}');
      //     // '${tempDir.path}/_File_Fixer_${imageFile.uri.pathSegments.last}');
      // await compressedFile.writeAsBytes(compressedImage);

      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<void> _pickDate(int index) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(9100),
    );

    if (pickedDate != null && index < _selectedDates.length) {
      setState(() {
        _selectedDates[index] = pickedDate;
      });
    }
  }

  // Future<void> _uploadImagesTODATABASE() async {
  //   if (!_isMounted) return;
  //   setState(() {
  //     _isUploading = true;
  //   });

  //   int successCount = 0;
  //   int failedCount = 0;

  //   for (int i = 0; i < _selectedImages.length; i++) {
  //     final url = Uri.parse(
  //         'https://api.verification.lifetimedesign.id/upload_App_FileFixer.php');
  //     final request = http.MultipartRequest('POST', url)
  //       ..files.add(
  //         await http.MultipartFile.fromPath(
  //           'image',
  //           _selectedImages[i].path,
  //         ),
  //       )
  //       ..fields['deskripsi'] = _descriptions[i] ?? ''
  //       ..fields['tanggal'] =
  //           _selectedDates[i]?.toIso8601String().split('T')[0] ?? ''
  //       ..fields['status'] = 'Waiting'
  //       ..fields['status_user'] = status ?? ''
  //       ..fields['username'] = username ?? ''
  //       ..fields['lokasi'] = lokasi ?? ''
  //       ..fields['userId'] = userId.toString()
  //       ..fields['tanggal_upload_hari_ini'] = DateTime.now().toString();

  //     // Jika status pengguna adalah "vendor", set fields['lokasi'] ke nilai lokasi dari informasi login
  //     if (status == 'vendor') {
  //       request.fields['company_name'] = companyName ?? '';
  //     } else {
  //       request.fields['company_name'] = _selectedCompanyNames[i] ?? '';
  //     }

  //     try {
  //       final response = await request.send();
  //       // ignore: unused_local_variable
  //       final responseString = await response.stream.bytesToString();
  //       if (response.statusCode == 200) {
  //         successCount++;
  //         print('Gambar ${i + 1} berhasil diupload.');
  //         // Navigator.pop(context, true);
  //       } else {
  //         failedCount++;
  //         print('Gambar ${i + 1} gagal diupload.');
  //       }
  //     } catch (e) {
  //       failedCount++;
  //       print('Terjadi kesalahan saat mengupload gambar ${i + 1}: $e');
  //     }
  //   }
  //   if (_isMounted) {
  //     // Periksa lagi sebelum memanggil setState
  //     setState(() {
  //       _isUploading = false;
  //     });
  //   }

  //   if (successCount > 0) {
  //     _showSnackbar('$successCount gambar berhasil diupload.');
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => HomePageSPA()),
  //         (Route<dynamic> route) => false);
  //   }
  //   if (failedCount > 0) {
  //     _showSnackbar('$failedCount gambar gagal diupload.');
  //   }

  //   setState(() {
  //     _isUploading = false;
  //   });

  //   // Cek status "admin" atau "super admin" pada tabel user
  //   final adminStatusList = ['vendor', 'procurement', 'super admin'];
  //   if (adminStatusList.contains(status)) {
  //     try {
  //       final response = await http.get(
  //         Uri.parse(
  //             'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_admin_users.php'),
  //       );
  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body) as List<dynamic>;
  //         for (final user in data) {
  //           final userId = user['id'] as String;
  //           final userStatus = user['status'] as String;
  //           final username = user['username'] as String;
  //           final fcmToken = user['fcm_token'] as String;

  //           if (adminStatusList.contains(userStatus)) {
  //             // Fungsi notifikasi
  //             final headers = {
  //               'Content-Type': 'application/json',
  //               'Authorization':
  //                   'key=AAAAiAk0jOI:APA91bGHlInl1P3I3QDc0txJFPi8WiwiVFB7gLhSw24pQ34ljqKWHlSy6SkDjuuu4JSZXazb9eYWE1TUzc8DTgZ_7y0gEqCIB6mhNPEGeGuAdtPxg2CNSRQh2iRiSyllK8DI3l31fq2B',
  //             };
  //             final notification = {
  //               'notification': {
  //                 'title': 'Ada pengajuan baru di terima',
  //                 'body': 'Lihat...!',
  //               },
  //               'data': {
  //                 'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //               },
  //               'to': fcmToken,
  //             };

  //             final response = await http.post(
  //               Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //               headers: headers,
  //               body: jsonEncode(notification),
  //             );

  //             if (response.statusCode == 200) {
  //               print('Notification sent successfully to $username');
  //             } else {
  //               print(
  //                   'Failed to send notification to $username. Status code: ${response.statusCode}');
  //             }
  //           }
  //         }
  //       } else {
  //         print(
  //             'Failed to fetch user data. Status code: ${response.statusCode}');
  //       }
  //     } catch (e) {
  //       print('Error fetching user data: $e');
  //     }
  //   }
  // }
  File xFileToFile(XFile xFile) {
    return File(xFile.path);
  }

  Future<void> _uploadImagesTODATABASE() async {
    if (!_isMounted) return;
    setState(() {
      _isUploading = true;
    });

    int successCount = 0;
    int failedCount = 0;

    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        final compressedFile =
            await compressImage(xFileToFile(_selectedImages[i]));
        if (compressedFile != null) {
          final url = Uri.parse(
              // 'https://menuku.id/flutter/validasifoto/upload_App_FileFixer.php');
              'https://api.verification.lifetimedesign.id/dummy_upload_App_FileFixer.php');
          // 'https://api.verification.lifetimedesign.id/upload_App_FileFixer.php');
          final request = http.MultipartRequest('POST', url)
            ..files.add(
              await http.MultipartFile.fromPath(
                'image',
                compressedFile.path,
              ),
            )
            ..fields['deskripsi'] = _descriptions[i] ?? ''
            ..fields['tanggal'] =
                _selectedDates[i]?.toIso8601String().split('T')[0] ?? ''
            ..fields['status'] = 'Waiting'
            ..fields['status_user'] = status ?? ''
            ..fields['username'] = username ?? ''
            ..fields['lokasi'] = lokasi ?? ''
            ..fields['userId'] = userId.toString()
            ..fields['tanggal_upload_hari_ini'] = DateTime.now().toString();

          // Jika status pengguna adalah "vendor", set fields['lokasi'] ke nilai lokasi dari informasi login
          if (status == 'vendor') {
            request.fields['company_name'] = companyName ?? '';
          } else {
            request.fields['company_name'] = _selectedCompanyNames[i] ?? '';
          }

          final response = await request.send();
          final responseString = await response.stream.bytesToString();
          if (response.statusCode == 200) {
            successCount++;
            print('Gambar ${i + 1} berhasil diupload.');
            // _showSuccessSnackbar('Gambar ${i + 1} berhasil diupload.');
          } else {
            failedCount++;
            print('Gambar ${i + 1} gagal diupload.');
            Navigator.pop(context);
            // _showErrorSnackbar('Gambar ${i + 1} gagal diupload.');
          }
        } else {
          failedCount++;
          print('Gambar ${i + 1} gagal dikompresi.');
          _showErrorSnackbar('Gambar ${i + 1} gagal dikompresi.');
          Navigator.pop(context);
        }
      } catch (e) {
        failedCount++;
        print('Terjadi kesalahan saat mengupload gambar ${i + 1}: $e');
        _showErrorSnackbar('Terjadi kesalahan saat mengupload gambar ${i + 1}');
      }
    }
    if (_isMounted) {
      setState(() {
        _isUploading = false;
      });
    }

    if (successCount > 0) {
      _showSuccessSnackbar('$successCount gambar berhasil diupload.');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePageSPA()),
          (Route<dynamic> route) => false);
    }
    if (failedCount > 0) {
      _showErrorSnackbar('Periksa koneksi internet atau coba lagi');
      Navigator.pop(context);
    }

    setState(() {
      _isUploading = false;
    });

    // Cek status "admin" atau "super admin" pada tabel user
    final adminStatusList = ['vendor', 'procurement', 'super admin'];
    if (adminStatusList.contains(status)) {
      try {
        final response = await http.get(
          Uri.parse(
              'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/get_admin_users.php'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as List<dynamic>;
          for (final user in data) {
            final userId = user['id'] as String;
            final userStatus = user['status'] as String;
            final username = user['username'] as String;
            final fcmToken = user['fcm_token'] as String;

            if (adminStatusList.contains(userStatus)) {
              // Fungsi notifikasi
              final headers = {
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAAiAk0jOI:APA91bGHlInl1P3I3QDc0txJFPi8WiwiVFB7gLhSw24pQ34ljqKWHlSy6SkDjuuu4JSZXazb9eYWE1TUzc8DTgZ_7y0gEqCIB6mhNPEGeGuAdtPxg2CNSRQh2iRiSyllK8DI3l31fq2B-a!',
              };
              final notification = {
                'notification': {
                  'title': 'Ada pengajuan baru di terima',
                  'body': 'Lihat...!',
                },
                'data': {
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                },
                'to': fcmToken,
              };

              final response = await http.post(
                Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: headers,
                body: jsonEncode(notification),
              );

              if (response.statusCode == 200) {
                print('Notification sent successfully to $username');
              } else {
                print(
                    'Failed to send notification to $username. Status code: ${response.statusCode}');
              }
            }
          }
        } else {
          print(
              'Failed to fetch user data. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSuccessSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSnackbar(String message) {
    // Pastikan widget masih terpasang sebelum menampilkan snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    // Navigator.pop(context, true);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePageSPA()),
        (Route<dynamic> route) => false);
    return false; // Return 'false' untuk mencegah aksi pop default (opsional).
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colorSet.pewter,
        appBar: AppBar(
          centerTitle: true,
          forceMaterialTransparency: true,
          backgroundColor: Colors.transparent,
          title: Text(
            "UPLOAD IMAGE",
            style: ThisTextStyle.bold22MainBg,
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (_selectedImages
                            .isNotEmpty) // Periksa bahwa _selectedImages tidak kosong
                          ...List.generate(
                            _selectedImages.length,
                            (index) {
                              // Pastikan indeks berada dalam batas daftar _selectedImages
                              if (index >= 0 &&
                                  index < _selectedImages.length) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Tampilkan gambar yang dipilih
                                      Container(
                                        height: 200,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 4,
                                              color: colorSet.mainGold),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.blueGrey,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: InkWell(
                                            onTap: () {
                                              // Buka gambar dalam layar penuh ketika gambar ditekan
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FullScreenImagePage2(
                                                    imagePath:
                                                        _selectedImages[index]
                                                            .path,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Image.file(
                                              File(_selectedImages[index].path),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Gap(8),
                                      Text(
                                        'Image ${index + 1}',
                                        style: ThisTextStyle.kdialog16,
                                      ),
                                      Gap(8),
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: TextField(
                                          // controller: dateInput,
                                          //editing controller of this TextField
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(
                                                Icons.calendar_today),
                                            hintText:
                                                _selectedDates[index] != null
                                                    ? _selectedDates[index]!
                                                        .toIso8601String()
                                                        .split('T')[0]
                                                    : "Pilih Tanggal Nota",
                                            filled: true,
                                            fillColor: colorSet.listTile1,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          readOnly: true,
                                          //set it true, so that user will not able to edit text
                                          onTap: () => _pickDate(index),
                                        ),
                                      ),
                                      if (status != 'vendor')
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colorSet.listTile1,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                        DropdownSearch<String>(
                                                      items: _locations,
                                                      selectedItem:
                                                          _selectedCompanyNames[
                                                              index],
                                                      dropdownDecoratorProps:
                                                          DropDownDecoratorProps(
                                                        dropdownSearchDecoration:
                                                            InputDecoration(
                                                          prefixIcon: Icon(
                                                              Icons.business),
                                                          filled: true,
                                                          fillColor: colorSet
                                                              .listTile1,
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          ),
                                                          hintText:
                                                              'Pilih Company/Vendor',
                                                        ),
                                                      ),
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          if (index <
                                                              _selectedCompanyNames
                                                                  .length) {
                                                            _selectedCompanyNames[
                                                                    index] =
                                                                value ??
                                                                    ''; // Set to empty string if null
                                                          }
                                                        });
                                                      },
                                                      popupProps:
                                                          PopupProps.menu(
                                                        showSearchBox: true,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Gap(8),
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: TextField(
                                          controller: _controllers[index],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.wallet),
                                            hintText: "Jumlah Harga",
                                            filled: true,
                                            fillColor: colorSet.listTile1,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              double parsedValue =
                                                  double.tryParse(value
                                                          .replaceAll('.', '')
                                                          .replaceAll(
                                                              ',', '')) ??
                                                      0.0;
                                              String formattedValue =
                                                  currencyFormatter
                                                      .format(parsedValue);
                                              _descriptions[index] =
                                                  formattedValue;
                                              _controllers[index].text =
                                                  formattedValue;
                                              _controllers[index].selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: _controllers[
                                                                  index]
                                                              .text
                                                              .length));
                                            });
                                          },
                                          // },
                                        ),
                                      ),
                                      Gap(16),
                                    ],
                                  ),
                                );
                              } else {
                                // Indeks berada di luar batas daftar _selectedImages
                                return Container();
                              }
                            },
                          ),
                        if (_selectedImages.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16),
                            child: Container(
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
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        false, // Mencegah pengguna menutup dialog dengan mengetuk di luar dialog
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: colorSet.mainGold,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: colorSet.listTile2,
                                              width: 2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Color.fromARGB(
                                                  215, 11, 11, 11),
                                            ), // Menampilkan indikator loading
                                            SizedBox(height: 16),
                                            Text('Uploading',
                                                style: TextStyle(
                                                    color: colorSet.mainBG,
                                                    fontWeight: FontWeight
                                                        .w400)), // Menampilkan teks "Uploading..."
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                  Future.delayed(Duration(seconds: 1), () {
                                    _uploadImagesTODATABASE(); // Memulai proses upload setelah menampilkan dialog
                                  });
                                },
                                child: _isUploading
                                    ? Text(
                                        'Uploading...',
                                        style: ThisTextStyle.bold16MainGold,
                                      )
                                    : Text(
                                        'Upload',
                                        style: ThisTextStyle.bold16MainGold,
                                      ),
                              ),
                            ),
                          ),
                        if (_selectedImages.isEmpty)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('PERHATIAN...!',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      content: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '- Pastikan gambar tidak terhalang',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text('  benda apapun',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text('- Pastikan gambar tegak lurus',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text('- Gambar harus jelas',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text(
                                              '- Dan mohon untuk tidak ada tangan',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text('  pada gambar',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await _pickImages('camera');
                                          },
                                          child: Text(
                                            'Next',
                                            style: TextStyle(
                                                color: Colors.greenAccent),
                                          ),
                                        ),
                                      ],
                                      backgroundColor: colorSet.mainBG,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: colorSet.mainGold, width: 2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 200,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorSet.mainBG,
                                        colorSet.mainGold
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 7,
                                        blurRadius: 7,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera,
                                        size: 100,
                                        color: colorSet.listTile1,
                                      ),
                                      Text(
                                        "CAMERA",
                                        style: TextStyle(
                                            color: colorSet.listTile1,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Gap(30),
                              GestureDetector(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('PERHATIAN...!',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      content: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('- Pilih maksimal 5 gambar',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text(
                                              '- Pastikan gambar tidak terhalang',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text('  benda apapun',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text('- Pastikan gambar tegak lurus',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text('- Gambar harus jelas',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text(
                                              '- Dan mohon untuk tidak ada tangan',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          Text('  pada gambar',
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await _pickImages('gallery');
                                          },
                                          child: Text(
                                            'Next',
                                            style: TextStyle(
                                                color: Colors.greenAccent),
                                          ),
                                        ),
                                      ],
                                      backgroundColor: colorSet.mainBG,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: colorSet.mainGold, width: 2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 200,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorSet.mainBG,
                                        colorSet.mainGold
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 7,
                                        blurRadius: 7,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.notes,
                                        size: 100,
                                        color: colorSet.listTile1,
                                      ),
                                      Text(
                                        "GALLERY",
                                        style: TextStyle(
                                            color: colorSet.listTile1,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
