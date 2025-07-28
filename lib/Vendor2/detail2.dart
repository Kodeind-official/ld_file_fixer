import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import '/UI/detail_foto.dart';
import '/Vendor2/home.dart';
import '/super_admin/detail2.dart';
import '/utility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class CustomImageInfo {
//   final String id;
//   final String userIdLogin;
//   final String filePath;
//   final String uploadDateOri;
//   final String uploadDate;
//   final String uploadDate2;
//   final String companyName;
//   String statusIMG;
//   final String deskripsi;
//   final String username;
//   final String statusReadVendor;
//   final String statusReadAdmin;
//   final String tanggal_upload_hari_ini;
//   late final String deskripsi_status;

//   CustomImageInfo(
//       {required this.id,
//       required this.userIdLogin,
//       required this.filePath,
//       required this.uploadDateOri,
//       required this.uploadDate,
//       required this.uploadDate2,
//       required this.companyName,
//       required this.statusIMG,
//       required this.username,
//       required this.deskripsi,
//       required this.statusReadVendor,
//       required this.statusReadAdmin,
//       required this.tanggal_upload_hari_ini,
//       required this.deskripsi_status});
// }

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

  // Future<void> _processImageAndRecognizeText(File image) async {
  //   final inputImage = img.decodeImage(image.readAsBytesSync());

  //   if (inputImage == null) {
  //     setState(() {
  //       _recognizedText = 'Error processing image';
  //       _textureInfo = 'Error processing image';
  //       _lineInfo = 'Error processing image';
  //     });
  //     return;
  //   }

  //   // Convert to grayscale
  //   final grayscaleImage = img.grayscale(inputImage);

  //   // Apply Gaussian blur to reduce noise
  //   final blurredImage = img.gaussianBlur(grayscaleImage, 1);

  //   // Analyze texture using Gabor filter
  //   final textureImage = _applyGaborFilter(blurredImage);

  //   // Analyze histogram
  //   final histogram = _computeHistogram(grayscaleImage);

  //   // Detect lines
  //   // final lineCount = _detectLines(grayscaleImage);

  //   // Prepare for OCR
  //   final inputImageForOCR = InputImage.fromFile(image);
  //   final textRecognizer = GoogleMlKit.vision.textRecognizer();
  //   final RecognizedText recognizedText =
  //       await textRecognizer.processImage(inputImageForOCR);

  //   // Count occurrences of letters A-Z, numbers 0-9, punctuation, and unique words
  //   Map<String, int> letterCounts = {};
  //   Map<String, int> numberCounts = {};
  //   Map<String, int> punctuationCounts = {};
  //   Set<String> uniqueWords = Set();

  //   for (int i = 0; i < recognizedText.text.length; i++) {
  //     String char = recognizedText.text[i];
  //     if (RegExp(r'[a-z]').hasMatch(char.toLowerCase())) {
  //       letterCounts[char.toLowerCase()] =
  //           (letterCounts[char.toLowerCase()] ?? 0) + 1;
  //     } else if (RegExp(r'[0-9]').hasMatch(char)) {
  //       numberCounts[char] = (numberCounts[char] ?? 0) + 1;
  //     } else if (RegExp(r'[^\w\s]').hasMatch(char)) {
  //       punctuationCounts[char] = (punctuationCounts[char] ?? 0) + 1;
  //     }

  //     // Collect unique words
  //     if (RegExp(r'\w').hasMatch(char)) {
  //       uniqueWords.add(char.toLowerCase());
  //     }
  //   }

  //   // Update recognized text, replace unreadable text with "*"
  //   setState(() {
  //     _recognizedText = recognizedText.text.isEmpty ? '*' : recognizedText.text;
  //     _textureInfo = 'Texture features and histogram calculated.';
  //     // _lineInfo = 'Number of lines detected: $lineCount';
  //     if (recognizedText.text.isEmpty) {
  //       // Pesan khusus jika tidak ada hasil OCR untuk gambar
  //       _secondRecognizedText = 'No OCR result for the second image';
  //     } else {
  //       _secondRecognizedText = recognizedText.text;
  //     }
  //     print('Letter Counts: $letterCounts');
  //     print('Number Counts: $numberCounts');
  //     print('Punctuation Counts: $punctuationCounts');
  //     print('Number of unique words: ${uniqueWords.length}');
  //   });

  //   await textRecognizer.close();
  // }

  // img.Image _applyGaborFilter(img.Image image) {
  //   final output = img.Image(image.width, image.height);
  //   // Apply Gabor filter (simple example, you might want to adjust parameters or use a library for a robust implementation)
  //   for (int y = 0; y < image.height; y++) {
  //     for (int x = 0; x < image.width; x++) {
  //       final pixel = image.getPixel(x, y);
  //       final luma = img.getLuminance(pixel);
  //       final gabor =
  //           (sin(2 * pi * luma / 256) + 1) / 2 * 255; // Simple Gabor filter
  //       output.setPixel(
  //           x, y, img.getColor(gabor.toInt(), gabor.toInt(), gabor.toInt()));
  //     }
  //   }
  //   return output;
  // }

  // List<int> _computeHistogram(img.Image image) {
  //   final histogram = List<int>.filled(256, 0);
  //   for (int y = 0; y < image.height; y++) {
  //     for (int x = 0; x < image.width; x++) {
  //       final pixel = image.getPixel(x, y);
  //       final luma = img.getLuminance(pixel);
  //       histogram[luma]++;
  //     }
  //   }
  //   return histogram;
  // }

  // // Fungsi untuk mengecek data yang cocok dalam database
  // double compareStrings(String a, String b) {
  //   int maxLength = a.length > b.length ? a.length : b.length;
  //   int editDistance = levenshteinDistance(a, b);
  //   return (1 - editDistance / maxLength) * 100;
  // }

  // int levenshteinDistance(String a, String b) {
  //   int m = a.length, n = b.length;
  //   List<List<int>> dp =
  //       List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));

  //   for (int i = 0; i <= m; i++) {
  //     for (int j = 0; j <= n; j++) {
  //       if (i == 0) {
  //         dp[i][j] = j;
  //       } else if (j == 0) {
  //         dp[i][j] = i;
  //       } else if (a[i - 1] == b[j - 1]) {
  //         dp[i][j] = dp[i - 1][j - 1];
  //       } else {
  //         dp[i][j] = 1 + _min(dp[i][j - 1], dp[i - 1][j], dp[i - 1][j - 1]);
  //       }
  //     }
  //   }
  //   return dp[m][n];
  // }

  // int _min(int x, int y, int z) {
  //   if (x <= y && x <= z) return x;
  //   if (y <= x && y <= z) return y;
  //   return z;
  // }

//   Future<void> checkMatchingData() async {
//     setState(() {
//       isLoading = true; // Indicates that the request is being processed
//     });

//     // Prepare parameters for the request
//     Map<String, String> requestBody = {
//       'company_name': widget.imageInfo.companyName,
//       'tanggal': widget.imageInfo.uploadDate,
//       'deskripsi': widget.imageInfo.deskripsi,
//       'exclude_id': widget.imageInfo.id,
//     };

//     try {
//       // Make HTTP request to the PHP endpoint
//       final response = await http.post(
//         Uri.parse(
//             'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/chek_existing.php'),
//         body: requestBody,
//       );

//       // Print response status code and body to the console
//       print('Response status code: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         // Decode response body
//         final List<dynamic> data = json.decode(response.body);

//         // Convert data to a list of CustomImageInfo
//         List<CustomImageInfo> resultList = data.map((item) {
//           return CustomImageInfo(
//             id: item['id'],
//             userIdLogin: item['userId'].toString(),
//             filePath: item['file_path'],
//             uploadDateOri: item['upload_date'],
//             uploadDate: item['upload_date'],
//             uploadDate2: item['upload_date'],
//             companyName: item['company_name'],
//             statusIMG: item['status'],
//             username: item['username'],
//             deskripsi: item['deskripsi'],
//             statusReadVendor: item['statusReadVendor'],
//             statusReadAdmin: item['statusReadAdmin'],
//             deskripsi_status: item['deskripsi_status'],
//             tanggal_upload_hari_ini:
//                 item['tanggal_upload_pengajuan'].toString(),
//           );
//         }).toList();

//         // Update state with the matched data
//         setState(() {
//           matchedData = resultList;
//         });

//         // Check and save OCR results for each matched data
//         if (resultList.isNotEmpty) {
//           for (var i = 0; i < resultList.length; i++) {
//             var data = resultList[i];
//             final selectedImageUrl =
//                 'https://api.verification.lifetimedesign.id/${widget.imageInfo.filePath}';
//             final imageUrl =
//                 'https://api.verification.lifetimedesign.id/${data.filePath}';

//             // Download images from URL
//             final imageResponse = await http.get(Uri.parse(imageUrl));
//             final imageResponse2 = await http.get(Uri.parse(selectedImageUrl));
//             final Directory tempDir = await getTemporaryDirectory();
//             final String tempPath = tempDir.path;

//             // Save images as temporary local files
//             final imageFile = File('$tempPath/${data.id}.jpg');
//             await imageFile.writeAsBytes(imageResponse.bodyBytes);

//             final imageFile2 = File('$tempPath/${data.id}_selected.jpg');
//             await imageFile2.writeAsBytes(imageResponse2.bodyBytes);

//             // Process images and recognize text using OCR
//             final ocrResult = await _processImage(imageFile);
//             final ocrResultimagepath = await _processImage(imageFile2);
//             print('OCR Result2: $ocrResultimagepath');
//             print('OCR Result: $ocrResult');

//             // Compare OCR results and print the similarity percentage
//             final percentage = compareStrings(
//                 ocrResultimagepath.toString(), ocrResult.toString());
//             print('Percentage of similarity: $percentage%');

//             // Store the comparison result
//             // Store the comparison result as a map
//             final Map<String, dynamic> comparisonResultMap = {
//               'ocrResult1': ocrResult.toString(),
//               'ocrResult2': ocrResultimagepath.toString(),
//               'similarityPercentage': percentage,
//             };

// // Add the comparison result map to the list
//             comparisonResults.add(comparisonResultMap);

//             // After finishing, you can delete temporary files if needed
//             await imageFile.delete();
//             await imageFile2.delete();
//           }
//         }
//       } else {
//         print('Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   double calculateSimilarity(Set<String> set1, Set<String> set2) {
//     final intersection = set1.intersection(set2);
//     final union = set1.union(set2);
//     return intersection.length / union.length * 100;
//   }

//   Future<Map<String, dynamic>> _processImage(File imageUrl) async {
//     final inputImage = img.decodeImage(imageUrl.readAsBytesSync());

//     if (inputImage == null) {
//       return {
//         'recognizedText': 'Error processing image',
//         'textureInfo': 'Error processing image',
//         'lineInfo': 'Error processing image',
//         'uniqueWords': {},
//         'punctuationCounts': {},
//         'numberCounts': {},
//         'letterCounts': {}
//       };
//     }

//     // Convert to grayscale
//     // final grayscaleImage = img.grayscale(inputImage);

//     // // Apply Gaussian blur to reduce noise
//     // final blurredImage = img.gaussianBlur(grayscaleImage, 1);

//     // // Analyze texture using Gabor filter
//     // final textureImage = _applyGaborFilter(blurredImage);

//     // // Analyze histogram
//     // final histogram = _computeHistogram(grayscaleImage);

//     // Detect lines
//     // final lineCount = _detectLines(grayscaleImage);

//     // Prepare for OCR
//     final inputImageForOCR = InputImage.fromFile(imageUrl);
//     final textRecognizer = GoogleMlKit.vision.textRecognizer();
//     final RecognizedText recognizedText =
//         await textRecognizer.processImage(inputImageForOCR);

//     // Count occurrences of letters A-Z, numbers 0-9, punctuation, and unique words
//     Map<String, int> letterCounts = {};
//     Map<String, int> numberCounts = {};
//     Map<String, int> punctuationCounts = {};
//     Set<String> uniqueWords = {};

//     for (int i = 0; i < recognizedText.text.length; i++) {
//       String char = recognizedText.text[i];
//       if (RegExp(r'[a-z]').hasMatch(char.toLowerCase())) {
//         letterCounts[char.toLowerCase()] =
//             (letterCounts[char.toLowerCase()] ?? 0) + 1;
//       } else if (RegExp(r'[0-9]').hasMatch(char)) {
//         numberCounts[char] = (numberCounts[char] ?? 0) + 1;
//       } else if (RegExp(r'[^\w\s]').hasMatch(char)) {
//         punctuationCounts[char] = (punctuationCounts[char] ?? 0) + 1;
//       }
//     }

//     // Count unique words
//     List<String> words = recognizedText.text.split(RegExp(r'\s+'));
//     for (String word in words) {
//       if (word.isNotEmpty) {
//         uniqueWords.add(word.toLowerCase());
//       }
//     }

//     return {
//       'recognizedText': recognizedText.text.isEmpty ? '*' : recognizedText.text,
//       'textureInfo': 'Texture features and histogram calculated.',
//       // 'lineInfo': 'Number of lines detected: $lineCount',
//       'uniqueWords': uniqueWords,
//       'punctuationCounts': punctuationCounts,
//       'numberCounts': numberCounts,
//       'letterCounts': letterCounts
//     };
//   }

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
          // bottomNavigationBar: Container(
          //   padding: const EdgeInsets.only(left: 24.0, right: 24, bottom: 8),
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: colorSet.mainBG,
          //       elevation: 0,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(15),
          //       ),
          //     ),
          //     onPressed: () async {
          //       setState(() {
          //         isLoading = true;
          //       });
          //       if (widget.imageInfo.status != 'Rejected' &&
          //           widget.imageInfo.status != 'Approved') {
          //         await updateImageStatus(widget.imageInfo.id, 'Process');
          //       }
          //       // Panggil fungsi asinkron seperti checkMatchingData
          //       await checkMatchingData();

          //       setState(() {
          //         isLoading = false;
          //       });
          //     },
          //     child: Text(
          //       isLoading ? 'Processing...' : 'Process Image',
          //       style: ThisTextStyle.bold16MainGold,
          //     ),
          //   ),
          // ),
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
                // if (matchedData.isNotEmpty)
                //   Center(
                //     child: Text(
                //       ('CHECK RESULTS'),
                //       style: TextStyle(fontSize: 16),
                //     ),
                //   ),

                // SizedBox(height: 10),

                // Divider(
                //   color: colorSet.mainBG,
                // ),
                // SizedBox(height: 16),
                // // Tampilkan hasil dat
                // // Konten Anda yang lain di sini
                // // Pastikan untuk memeriksa kondisi isNotEmpty dan indeks valid

                // if (matchedData.isNotEmpty)
                //   isLoading
                //       ? Center(
                //           child: CircularProgressIndicator(
                //             color: colorSet.mainBG,
                //           ),
                //         )
                //       : Column(
                //           children: List.generate(matchedData.length, (index) {
                //             // comparisonResults.sort((a, b) =>
                //             //     b['similarityPercentage']
                //             //         .compareTo(a['similarityPercentage']));
                //             Color containerColor = index.isOdd
                //                 ? colorSet.listTile2
                //                 : colorSet.listTile1;
                //             final data = matchedData[index];
                //             if (comparisonResults.isNotEmpty &&
                //                 index < comparisonResults.length) {
                //               final comparisonResult = comparisonResults[index];
                //               return Column(
                //                 children: [
                //                   Container(
                //                     decoration: BoxDecoration(
                //                       borderRadius: BorderRadius.circular(15),
                //                       color: containerColor,
                //                     ),
                //                     child: ListTile(
                //                       leading: CircleAvatar(
                //                         child: InkWell(
                //                           onTap: () {
                //                             Navigator.push(
                //                               context,
                //                               MaterialPageRoute(
                //                                 builder: (context) =>
                //                                     FullScreenImagePage(
                //                                   imageUrls: [
                //                                     'https://api.verification.lifetimedesign.id/${data.filePath}',
                //                                   ],
                //                                   initialIndex: 0,
                //                                 ),
                //                               ),
                //                             );
                //                           },
                //                           child: CircleAvatar(
                //                             child: ClipOval(
                //                               child: Image.network(
                //                                 'https://api.verification.lifetimedesign.id/${data.filePath}',
                //                                 width: 50,
                //                                 height: 50,
                //                                 fit: BoxFit.cover,
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                       title: Text(
                //                         data.companyName,
                //                         style: TextStyle(fontSize: 16),
                //                       ),
                //                       subtitle: Column(
                //                         crossAxisAlignment:
                //                             CrossAxisAlignment.start,
                //                         mainAxisAlignment:
                //                             MainAxisAlignment.start,
                //                         children: [
                //                           Row(
                //                             children: [
                //                               Text('Similarity    :  '),
                //                               Text(
                //                                 '${(comparisonResult['similarityPercentage']).toStringAsFixed(2)}%',
                //                                 style: TextStyle(
                //                                     color: Colors.red),
                //                               ),
                //                             ],
                //                           ),
                //                           Row(
                //                             children: [
                //                               Text('Total            :  '),
                //                               Text(
                //                                 data.deskripsi,
                //                                 style: TextStyle(
                //                                     color: Colors.red),
                //                               ),
                //                             ],
                //                           ),
                //                           Row(
                //                             children: [
                //                               Text('Order Date  :  '),
                //                               Text(
                //                                 formatDate(data.uploadDate2),
                //                                 style: TextStyle(
                //                                     color: Colors.red),
                //                               ),
                //                             ],
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                   ),
                //                   SizedBox(height: 22),
                //                 ],
                //               );
                //             } else {
                //               return Container(); // Anda bisa menambahkan fallback di sini
                //             }
                //           }),
                //         ),
                // if (matchedData.isEmpty && !isLoading) Text('No Result'),
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
