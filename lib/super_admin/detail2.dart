// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import '/UI/detail_foto.dart';
import '/super_admin/home.dart';
import '/utility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_mlkit_commons/google_mlkit_commons.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CustomImageInfo {
  final String id;
  final String userIdLogin;
  final String filePath;
  final String uploadDateOri;
  final String uploadDate;
  final String uploadDate2;
  final String companyName;
  String statusIMG;
  final String deskripsi;
  final String username;
  final String statusReadVendor;
  String statusReadAdmin;
  final String tanggal_upload_hari_ini;
  late final String deskripsi_status;
  bool hasChangedStatus = false;

  CustomImageInfo(
      {required this.id,
      required this.userIdLogin,
      required this.filePath,
      required this.uploadDateOri,
      required this.uploadDate,
      required this.uploadDate2,
      required this.companyName,
      required this.statusIMG,
      required this.username,
      required this.deskripsi,
      required this.statusReadVendor,
      required this.statusReadAdmin,
      required this.tanggal_upload_hari_ini,
      this.hasChangedStatus = false,
      required this.deskripsi_status});
}

class DetailPageSPA extends StatefulWidget {
  final CustomImageInfo imageInfo;

  DetailPageSPA({required this.imageInfo});

  @override
  _DetailPageSPAState createState() => _DetailPageSPAState();
}

class _DetailPageSPAState extends State<DetailPageSPA> {
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
      // if (widget.imageInfo.statusReadAdmin != 'read' &&
      //     widget.imageInfo.statusReadAdmin != 'read false status') {
      //   await updateStatusReadAdmin(widget.imageInfo.id);
      // }
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

  Future<void> updateStatusReadAdmin2(String imageId) async {
    // Buat permintaan HTTP untuk memperbarui statusReadAdmin menjadi "true"
    final url = Uri.parse(
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

  // Fungsi untuk mengecek data yang cocok dalam database
  double compareStrings(String a, String b) {
    int maxLength = a.length > b.length ? a.length : b.length;
    int editDistance = levenshteinDistance(a, b);
    return (1 - editDistance / maxLength) * 100;
  }

  int levenshteinDistance(String a, String b) {
    int m = a.length, n = b.length;
    List<List<int>> dp =
        List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      for (int j = 0; j <= n; j++) {
        if (i == 0) {
          dp[i][j] = j;
        } else if (j == 0) {
          dp[i][j] = i;
        } else if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + _min(dp[i][j - 1], dp[i - 1][j], dp[i - 1][j - 1]);
        }
      }
    }
    return dp[m][n];
  }

  int _min(int x, int y, int z) {
    if (x <= y && x <= z) return x;
    if (y <= x && y <= z) return y;
    return z;
  }

  Future<void> checkMatchingData() async {
    setState(() {
      isLoading = true; // Indicates that the request is being processed
    });

    // Prepare parameters for the request
    Map<String, String> requestBody = {
      'id': widget.imageInfo.id,
      'company_name': widget.imageInfo.companyName,
      'tanggal': widget.imageInfo.uploadDate,
      'deskripsi': widget.imageInfo.deskripsi,
      'exclude_id': widget.imageInfo.id,
    };

    try {
      // Make HTTP request to the PHP endpoint
      final response = await http.post(
        Uri.parse(
            'https://api.verification.lifetimedesign.id/App/Validasi/App_FileFixer/chek_existing.php'),
        body: requestBody,
      );

      // Print response status code and body to the console
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode response body
        final List<dynamic> data = json.decode(response.body);

        // Convert data to a list of CustomImageInfo
        List<CustomImageInfo> resultList = data.map((item) {
          return CustomImageInfo(
            id: item['id'],
            userIdLogin: item['userId'].toString(),
            filePath: item['file_path'],
            uploadDateOri: item['upload_date'],
            uploadDate: item['upload_date'],
            uploadDate2: item['upload_date'],
            companyName: item['company_name'],
            statusIMG: item['status'],
            username: item['username'],
            deskripsi: item['deskripsi'],
            statusReadVendor: item['statusReadVendor'],
            statusReadAdmin: item['statusReadAdmin'],
            deskripsi_status: item['deskripsi_status'],
            tanggal_upload_hari_ini:
                item['tanggal_upload_pengajuan'].toString(),
          );
        }).toList();

        // Update state with the matched data
        setState(() {
          matchedData = resultList;
        });

        // Check and save OCR results for each matched data
        if (resultList.isNotEmpty) {
          for (var i = 0; i < resultList.length; i++) {
            var data = resultList[i];
            final selectedImageUrl =
                'https://api.verification.lifetimedesign.id/${widget.imageInfo.filePath}';
            final imageUrl =
                'https://api.verification.lifetimedesign.id/${data.filePath}';

            // Download images from URL
            final imageResponse = await http.get(Uri.parse(imageUrl));
            final imageResponse2 = await http.get(Uri.parse(selectedImageUrl));
            final Directory tempDir = await getTemporaryDirectory();
            final String tempPath = tempDir.path;

            // Save images as temporary local files
            final imageFile = File('$tempPath/${data.id}.jpg');
            await imageFile.writeAsBytes(imageResponse.bodyBytes);

            final imageFile2 = File('$tempPath/${data.id}_selected.jpg');
            await imageFile2.writeAsBytes(imageResponse2.bodyBytes);

            // Process images and recognize text using OCR
            final ocrResult = await _processImage(imageFile);
            final ocrResultimagepath = await _processImage(imageFile2);
            print('OCR Result2: $ocrResultimagepath');
            print('OCR Result: $ocrResult');

            // Compare OCR results and print the similarity percentage
            final percentage = compareStrings(
                ocrResultimagepath.toString(), ocrResult.toString());
            print('Percentage of similarity: $percentage%');

            // Store the comparison result
            // Store the comparison result as a map
            final Map<String, dynamic> comparisonResultMap = {
              'ocrResult1': ocrResult.toString(),
              'ocrResult2': ocrResultimagepath.toString(),
              'similarityPercentage': percentage,
            };

// Add the comparison result map to the list
            comparisonResults.add(comparisonResultMap);

            // After finishing, you can delete temporary files if needed
            await imageFile.delete();
            await imageFile2.delete();
          }
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double calculateSimilarity(Set<String> set1, Set<String> set2) {
    final intersection = set1.intersection(set2);
    final union = set1.union(set2);
    return intersection.length / union.length * 100;
  }

  Future<Map<String, dynamic>> _processImage(File imageUrl) async {
    final inputImage = img.decodeImage(imageUrl.readAsBytesSync());

    if (inputImage == null) {
      return {
        'recognizedText': 'Error processing image',
        'textureInfo': 'Error processing image',
        'lineInfo': 'Error processing image',
        'uniqueWords': {},
        'punctuationCounts': {},
        'numberCounts': {},
        'letterCounts': {}
      };
    }

    final inputImageForOCR = InputImage.fromFile(imageUrl);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImageForOCR);
    // Count occurrences of letters A-Z, numbers 0-9, punctuation, and unique words
    Map<String, int> letterCounts = {};
    Map<String, int> numberCounts = {};
    Map<String, int> punctuationCounts = {};
    Set<String> uniqueWords = {};

    for (int i = 0; i < recognizedText.text.length; i++) {
      String char = recognizedText.text[i];
      if (RegExp(r'[a-z]').hasMatch(char.toLowerCase())) {
        letterCounts[char.toLowerCase()] =
            (letterCounts[char.toLowerCase()] ?? 0) + 1;
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        numberCounts[char] = (numberCounts[char] ?? 0) + 1;
      } else if (RegExp(r'[^\w\s]').hasMatch(char)) {
        punctuationCounts[char] = (punctuationCounts[char] ?? 0) + 1;
      }
    }

    // Count unique words
    List<String> words = recognizedText.text.split(RegExp(r'\s+'));
    for (String word in words) {
      if (word.isNotEmpty) {
        uniqueWords.add(word.toLowerCase());
      }
    }

    return {
      'recognizedText': recognizedText.text.isEmpty ? '*' : recognizedText.text,
      'textureInfo': 'Texture features and histogram calculated.',
      // 'lineInfo': 'Number of lines detected: $lineCount',
      'uniqueWords': uniqueWords,
      'punctuationCounts': punctuationCounts,
      'numberCounts': numberCounts,
      'letterCounts': letterCounts
    };
  }

//  Future<void> _processImage(CustomImageInfo imageInfo) async {
//     try {
//       // Load the first image from the file path
//       final firstImageFile = File(widget.imageInfo.filePath);
//       final firstInputImage = InputImage.fromFile(firstImageFile);

//       // Recognize text in the first image
//       final firstTextRecognizer = TextRecognizer();
//       final firstRecognizedText = await firstTextRecognizer.processImage(firstInputImage);

//       // Extract text from the recognized text
//       _recognizedText = firstRecognizedText.text;

//       // Load the second image from the file path
//       final secondImageFile = File(imageInfo.filePath);
//       final secondInputImage = InputImage.fromFile(secondImageFile);

//       // Recognize text in the second image
//       final secondTextRecognizer = TextRecognizer();
//       final secondRecognizedText = await secondTextRecognizer.processImage(secondInputImage);

//       // Extract text from the recognized text
//       _secondRecognizedText = secondRecognizedText.text;

//       // Calculate similarity percentage between the two texts
//       double similarityPercentage = compareStrings(_recognizedText, _secondRecognizedText);
//       print('Similarity Percentage between ${widget.imageInfo.filePath} and ${imageInfo.filePath}: $similarityPercentage%');

//       // Update the total similarity percentage
//       setState(() {
//         totalSimilarityPercentage = (totalSimilarityPercentage + similarityPercentage) / 2;
//       });

//       // Update the statusIMG based on the similarity percentage
//       if (similarityPercentage > 50) {
//         imageInfo.statusIMG = 'similar';
//       } else {
//         imageInfo.statusIMG = 'not similar';
//       }

//       // Update the comparison results
//       setState(() {
//         comparisonResults.add({
//           'firstImagePath': widget.imageInfo.filePath,
//           'secondImagePath': imageInfo.filePath,
//           'similarityPercentage': similarityPercentage,
//         });
//       });

//       // Cleanup
//       await firstTextRecognizer.close();
//       await secondTextRecognizer.close();
//     } catch (error) {
//       print('Error processing image: $error');
//     }
//   }

  Future<bool> _onWillPop() async {
    // Navigator.pop(context, true);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomePageSPA()),
        (Route<dynamic> route) => false);

    return false; // Return 'false' untuk mencegah aksi pop default (opsional).
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: colorSet.pewter,
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(left: 24.0, right: 24, bottom: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorSet.mainBG,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                setState(() {
                  widget.imageInfo.statusReadAdmin =
                      'read'; // Ubah statusReadAdmin
                });

                //             if (widget.imageInfo.status != 'Rejected' &&
                //                 widget.imageInfo.status != 'Approved') {
                //               await updateImageStatus(widget.imageInfo.id, 'Process');
                //             setState(() {
                //     widget.imageInfo.status = 'Process';
                //   });
                // }
                // Panggil fungsi asinkron seperti checkMatchingData
                await checkMatchingData();
                if (widget.imageInfo.statusReadAdmin != 'read' &&
                    widget.imageInfo.statusReadAdmin != 'read false status') {}
                await updateStatusReadAdmin(widget.imageInfo.id);

                setState(() {
                  isLoading = false;
                });
              },
              child: Text(
                isLoading ? 'Processing...' : 'Process Image',
                style: ThisTextStyle.bold16MainGold,
              ),
            ),
          ),
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
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(left: 18, right: 18),
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.end,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         'NOTA-',
                //         style: ThisTextStyle.bold14MainGold
                //       ),
                //       Text(
                //         formatDateYear(
                //             widget.imageInfo.tanggal_upload_hari_ini),
                //         style: ThisTextStyle.bold14MainGold
                //       ),
                //       Text(
                //         '${"-" + widget.imageInfo.id}',
                //        style: ThisTextStyle.bold14MainGold
                //       ),
                //     ],
                //   ),
                // ),

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
                          height: 200,
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
                          'Order Date     :   ${widget.imageInfo.uploadDate2}')),
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
                            Text('Status              :   '),
                            status == 'procurement' &&
                                    widget.imageInfo.statusIMG == 'Rejected'
                                ? Text(
                                    widget.imageInfo.statusIMG,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorSet.mainGold,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : (widget.imageInfo.statusReadAdmin ==
                                            'unread' &&
                                        status != 'vendor')
                                    ? Text(
                                        widget.imageInfo.statusIMG,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorSet.mainGold,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: widget.imageInfo.statusIMG !=
                                                    'Approved' &&
                                                (status == 'super admin' ||
                                                    widget.imageInfo
                                                            .statusReadAdmin !=
                                                        'read false status')
                                            ? () {
                                                // Show a dialog or implement a custom selection mechanism
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          colorSet.mainGold,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: colorSet
                                                                .listTile1,
                                                            width: 2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      title: Center(
                                                          child: Text(
                                                        'Select Status',
                                                        style: TextStyle(
                                                            color: colorSet
                                                                .mainBG),
                                                      )),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          SizedBox(height: 10),
                                                          if (status !=
                                                              'procurement')
                                                            GestureDetector(
                                                              onTap: () {
                                                                updateImageStatus(
                                                                    widget
                                                                        .imageInfo
                                                                        .id,
                                                                    'Waiting');
                                                                setState(() {
                                                                  widget.imageInfo
                                                                          .statusIMG =
                                                                      'Waiting';
                                                                });
                                                                Navigator.pop(
                                                                    context); // Close the dialog
                                                              },
                                                              child: Container(
                                                                width: 190,
                                                                height: 40,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: colorSet
                                                                      .listTile1,
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                      'Waiting',
                                                                      style: TextStyle(
                                                                          color: colorSet
                                                                              .mainBG,
                                                                          fontWeight:
                                                                              FontWeight.w600)),
                                                                ),
                                                              ),
                                                            ),
                                                          SizedBox(height: 28),
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    backgroundColor:
                                                                        colorSet
                                                                            .mainGold,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      side: BorderSide(
                                                                          color: colorSet
                                                                              .listTile2,
                                                                          width:
                                                                              2),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    title: Text(
                                                                        "Confirmation",
                                                                        style: TextStyle(
                                                                            color:
                                                                                colorSet.mainBG)),
                                                                    content: Text(
                                                                        "Are you sure you want to approve this image?"),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          if (mounted) {
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              90,
                                                                          height:
                                                                              40,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            color:
                                                                                colorSet.listTile2,
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              "Cancel",
                                                                              style: TextStyle(color: colorSet.mainBG),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          if (mounted) {}
                                                                          await updateImageStatus(
                                                                              widget.imageInfo.id,
                                                                              'Approved');
                                                                          if (mounted) {
                                                                            setState(() {
                                                                              updateStatusReadAdmin2(widget.imageInfo.id);
                                                                              widget.imageInfo.statusIMG = 'Approved';
                                                                            });
                                                                            if (mounted) {
                                                                              Navigator.pop(context); // Close the dialog
                                                                              Navigator.pop(context);
                                                                            }
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              90,
                                                                          height:
                                                                              40,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            color:
                                                                                colorSet.mainBG,
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              "Confirm",
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
                                                            child: Container(
                                                              width: 190,
                                                              height: 40,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: colorSet
                                                                    .listTile1,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  'Approve',
                                                                  style:
                                                                      TextStyle(
                                                                    color: colorSet
                                                                        .mainGold,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 28),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context); // Tutup dialog
                                                              updateImageStatus(
                                                                  widget
                                                                      .imageInfo
                                                                      .id,
                                                                  'Rejected',
                                                                  onSubmit: () {
                                                                setState(() {
                                                                  widget.imageInfo
                                                                          .statusIMG =
                                                                      'Rejected';
                                                                  if (status ==
                                                                          'procurement' &&
                                                                      widget.imageInfo
                                                                              .statusIMG ==
                                                                          'Rejected') {
                                                                    // Change the widget to Text
                                                                    widget.imageInfo
                                                                            .statusIMG =
                                                                        'Rejected';
                                                                  }
                                                                  updateStatusReadAdmin2(
                                                                      widget
                                                                          .imageInfo
                                                                          .id);
                                                                });
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 190,
                                                              height: 40,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: colorSet
                                                                    .listTile1,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                    'Rejected',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .redAccent,
                                                                        fontWeight:
                                                                            FontWeight.w600)),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            : null,
                                        child: Text(
                                          widget.imageInfo
                                              .statusIMG, // Tampilkan status saat ini
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: colorSet.mainGold,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Tampilkan gambar dari URL

                // SizedBox(height: 16),
                // Tombol cek

                SizedBox(height: 16),
                if (matchedData.isNotEmpty)
                  Center(
                    child: Text(
                      ('CHECK RESULTS'),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                SizedBox(height: 10),
                Divider(
                  color: colorSet.mainBG,
                ),
                SizedBox(height: 16),
                // Tampilkan hasil dat
                // Konten Anda yang lain di sini
                // Pastikan untuk memeriksa kondisi isNotEmpty dan indeks valid

                if (matchedData.isNotEmpty)
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: colorSet.mainBG,
                          ),
                        )
                      : Column(
                          children: List.generate(matchedData.length, (index) {
                            Color containerColor = index.isOdd
                                ? colorSet.listTile2
                                : colorSet.listTile1;
                            final data = matchedData[index];
                            if (comparisonResults.isNotEmpty &&
                                index < comparisonResults.length) {
                              final comparisonResult = comparisonResults[index];
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FullScreenImagePageResult(
                                            imageUrls: matchedData
                                                .map((data) =>
                                                    'https://api.verification.lifetimedesign.id/${data.filePath}')
                                                .toList(),
                                            initialIndex: index,
                                            imageData: matchedData.map((data) {
                                              final comparisonResult =
                                                  comparisonResults[matchedData
                                                      .indexOf(data)];
                                              return {
                                                'companyName': data.companyName,
                                                'uploadDate': formatDateYear(data
                                                    .tanggal_upload_hari_ini),
                                                'id': data.id,
                                                'similarityPercentage':
                                                    comparisonResult[
                                                        'similarityPercentage'],
                                                'total': data.deskripsi,
                                                'uploadDateDetail': formatDate(
                                                    data.tanggal_upload_hari_ini),
                                              };
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: containerColor,
    border: Border.all(
      color: comparisonResult['similarityPercentage'] >= 50
          ? Colors.red
          : Colors.transparent, // Kondisi border merah
      width: 2.0, // Ketebalan border
    ),
  ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FullScreenImagePageResult(
                                                    imageUrls: matchedData
                                                        .map((data) =>
                                                            'https://api.verification.lifetimedesign.id/${data.filePath}')
                                                        .toList(),
                                                    initialIndex: index,
                                                    imageData:
                                                        matchedData.map((data) {
                                                      final comparisonResult =
                                                          comparisonResults[
                                                              matchedData
                                                                  .indexOf(
                                                                      data)];
                                                      return {
                                                        'companyName':
                                                            data.companyName,
                                                        'uploadDate':
                                                            formatDateYear(data
                                                                .tanggal_upload_hari_ini),
                                                        'id': data.id,
                                                        'similarityPercentage':
                                                            comparisonResult[
                                                                'similarityPercentage'],
                                                        'total': data.deskripsi,
                                                        'uploadDateDetail':
                                                            formatDate(data
                                                                .tanggal_upload_hari_ini),
                                                      };
                                                    }).toList(),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              child: ClipOval(
                                                child: Image.network(
                                                  'https://api.verification.lifetimedesign.id/${data.filePath}',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            data.companyName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: colorSet.mainBG,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 0.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'NOTA',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      // color: colorSet.mainBG
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   formatDateYear(data
                                                  //       .tanggal_upload_hari_ini),
                                                  //   style: TextStyle(
                                                  //     fontWeight:
                                                  //         FontWeight.w500,
                                                  //     fontSize: 12,
                                                  //     // color: colorSet.mainBG
                                                  //   ),
                                                  // ),
                                                  Text(
                                                    '${"-" + data.id}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      // color: colorSet.mainBG
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Row(
                                                children: [
                                                  Text('Similarity'),
                                                  Text('         :  '),
                                                  Text(
                                                    '${(comparisonResult['similarityPercentage']).toStringAsFixed(2)}%',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text('Total'),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 2),
                                                    child: Text(
                                                        '                :  '),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "Rp. ${data.deskripsi}",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text('Upload Date'),
                                                  Text('    :  '),
                                                  Text(
                                                    formatDate(data
                                                        .tanggal_upload_hari_ini),
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 22),
                                ],
                              );
                            } else {
                              return Container(); // Anda bisa menambahkan fallback di sini
                            }
                          }),
                        ),
                if (matchedData.isEmpty && !isLoading) Text('No Result'),
              ],
            ),
          ),
        ));
  }

  String formatDateTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate =
        '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
    return formattedDate;
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM yyyy').format(parsedDate);
  }

  String formatDateYear(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy').format(parsedDate);
  }

  // Future<void> sendNotification(String username, String fcmToken) async {
  //   // if (fcmToken.isNotEmpty) {
  //   Map<String, String> headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization':
  //         'key=AAAAiAk0jOI:APA91bGHlInl1P3I3QDc0txJFPi8WiwiVFB7gLhSw24pQ34ljqKWHlSy6SkDjuuu4JSZXazb9eYWE1TUzc8DTgZ_7y0gEqCIB6mhNPEGeGuAdtPxg2CNSRQh2iRiSyllK8DI3l31fq2B',
  //   };

  //   // Send notification
  //   final response = await http.post(
  //     Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //     headers: headers,
  //     body: jsonEncode({
  //       'notification': {
  //         'to': fcmToken,
  //         'title': 'Pengajuan anda di $status',
  //         'body': 'Lihat Pengajuan...!',
  //       },
  //       'data': {
  //         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //         'image_id': widget.imageInfo.id,
  //         'user_id': widget.imageInfo.userIdLogin,
  //         'file_path': widget.imageInfo.filePath,
  //         'upload_date_ori': widget.imageInfo.uploadDateOri,
  //         'upload_date': widget.imageInfo.uploadDate,
  //         'upload_date_2': widget.imageInfo.uploadDate2,
  //         'company_name': widget.imageInfo.companyName,
  //         'status': widget.imageInfo.statusIMG,
  //         'username': widget.imageInfo.username,
  //         'description': widget.imageInfo.deskripsi,
  //         'status_read_vendor': widget.imageInfo.statusIMGReadVendor,
  //         'status_read_admin': widget.imageInfo.statusIMGReadAdmin,
  //         'tanggal_upload_hari_ini': widget.imageInfo.tanggal_upload_hari_ini,
  //         'description_status': widget.imageInfo.deskripsi_status,
  //       },
  //       'to': fcmToken,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     print('Notification sent successfully to $username');
  //   } else {
  //     print(
  //         'Failed to send notification to $username. Status code: ${response.statusCode}');
  //   }
  //   // } else {
  //   //   print('FCM Token is empty for user $username');
  //   // }
  // }

  Future<void> sendNotification(String username, String fcmToken,
      String newStatus, String deskripsiImage) async {
    // Jika fcmToken tidak kosong
    if (fcmToken.isNotEmpty) {
      String filePath = widget.imageInfo.filePath;
      if (newStatus == 'Rejected') {
        filePath = filePath.replaceFirst('uploads', 'Reject');
      }

      if (newStatus == 'Approved') {
        filePath = filePath.replaceFirst('Reject', 'uploads');
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAiAk0jOI:APA91bGHlInl1P3I3QDc0txJFPi8WiwiVFB7gLhSw24pQ34ljqKWHlSy6SkDjuuu4JSZXazb9eYWE1TUzc8DTgZ_7y0gEqCIB6mhNPEGeGuAdtPxg2CNSRQh2iRiSyllK8DI3l31fq2B',
      };

      // Data notifikasi
      Map<String, dynamic> notificationData = {
        'to': fcmToken,
        'title': '$newStatus',
        'body': 'Ketuk untuk lihat pengajuan anda...!',
      };

      // Data kustom
      Map<String, dynamic> customData = {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'image_id': widget.imageInfo.id,
        'user_id': widget.imageInfo.userIdLogin,
        'file_path': filePath,
        'upload_date_ori': widget.imageInfo.uploadDateOri,
        'upload_date': widget.imageInfo.uploadDate,
        'upload_date_2': widget.imageInfo.uploadDate2,
        'company_name': widget.imageInfo.companyName,
        'status': newStatus,
        'username': widget.imageInfo.username,
        'description': widget.imageInfo.deskripsi,
        'status_read_vendor': widget.imageInfo.statusReadVendor,
        'status_read_admin': widget.imageInfo.statusReadAdmin,
        'tanggal_upload_hari_ini': widget.imageInfo.tanggal_upload_hari_ini,
        'description_status': deskripsiImage
      };

      // Print data sebelum mengirim notifikasi
      print('Data notifikasi: $notificationData');
      print('Data kustom: $customData');

      // Kirim notifikasi
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headers,
        body: jsonEncode({
          'notification': notificationData,
          'data': customData,
          'to': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print('Notifikasi berhasil dikirim ke $username');
      } else {
        print(
            'Gagal mengirim notifikasi ke $username. Kode status: ${response.statusCode}');
      }
    } else {
      print('Token FCM kosong untuk pengguna $username');
    }
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

  Future<void> getUserInfoAndSendNotification(
      int userId, String newStatus, String deskripsiImage) async {
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
          await sendNotification(username, fcmToken, newStatus, deskripsiImage);
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
