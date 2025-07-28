import 'dart:io';

import 'package:flutter/material.dart';
import '/utility.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImagePage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  FullScreenImagePage({required this.imageUrls, this.initialIndex = 0});

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  // Future<bool> _onWillPop() async {
  //   Navigator.pop(context, true);
  //   return false; // Return 'false' untuk mencegah aksi pop default (opsional).
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorSet.pewter,
      appBar: AppBar(backgroundColor: colorSet.pewter,),
      body: Container(
        child: PhotoViewGallery.builder(
          itemCount: widget.imageUrls.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(widget.imageUrls[index]),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: BouncingScrollPhysics(),
          backgroundDecoration: BoxDecoration(
            color: Colors.black,
          ),
          pageController: PageController(initialPage: widget.initialIndex),
        ),
      ),
    );
  }
}

class FullScreenImagePage2 extends StatefulWidget {
  final String imagePath;

  FullScreenImagePage2({required this.imagePath});

  @override
  State<FullScreenImagePage2> createState() => _FullScreenImagePage2State();
}

class _FullScreenImagePage2State extends State<FullScreenImagePage2> {
  // Future<bool> _onWillPop() async {
  //   Navigator.pop(context, true);
  //   return false; // Return 'false' untuk mencegah aksi pop default (opsional).
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorSet.pewter,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // Tutup layar penuh saat tombol tutup ditekan
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.contain,
        ),
      ),
      // backgroundColor: Colors.black, // Background hitam untuk tampilan penuh
    );
  }
}

// class FullScreenImagePageResult extends StatefulWidget {
//   final List<String> imageUrls;
//   final int initialIndex;

//   FullScreenImagePageResult({required this.imageUrls, this.initialIndex = 0});

//   @override
//   State<FullScreenImagePageResult> createState() => _FullScreenImagePageResultState();
// }

// class _FullScreenImagePageResultState extends State<FullScreenImagePageResult> {
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Full Screen Image'),
//       ),
//       body: PhotoViewGallery.builder(
//         itemCount: widget.imageUrls.length,
//         builder: (context, index) {
//           return PhotoViewGalleryPageOptions(
//             imageProvider: NetworkImage(widget.imageUrls[index]),
//             minScale: PhotoViewComputedScale.contained * 0.8,
//             maxScale: PhotoViewComputedScale.covered * 2,
//           );
//         },
//         scrollPhysics: BouncingScrollPhysics(),
//         backgroundDecoration: BoxDecoration(
//           color: Colors.black,
//         ),
//         pageController: _pageController,
//       ),
//     );
//   }
// }

class FullScreenImagePageResult extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final List<Map<String, dynamic>>
      imageData; // List to store all data related to images

  FullScreenImagePageResult({
    required this.imageUrls,
    this.initialIndex = 0,
    required this.imageData,
  });

  @override
  State<FullScreenImagePageResult> createState() =>
      _FullScreenImagePageResultState();
}

class _FullScreenImagePageResultState extends State<FullScreenImagePageResult> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentData = widget.imageData[_currentIndex];
    return Scaffold(
      backgroundColor: colorSet.pewter,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'IMAGE COMPARISON RESULTS',
          style: ThisTextStyle.bold18MainBg,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PhotoViewGallery.builder(
              itemCount: widget.imageUrls.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.imageUrls[index]),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
              pageController: _pageController,
              onPageChanged: _onPageChanged,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentData['companyName'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('NOTA-'),
                    Text(currentData['uploadDate']),
                    Text('-${currentData['id']}'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Similarity'),
                    Text(': '),
                    Text(
                      '${currentData['similarityPercentage'].toStringAsFixed(2)}%',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Total'),
                    Text(': '),
                    Expanded(
                      child: Text(
                        "Rp. ${currentData['total']}",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Upload Date'),
                    Text(': '),
                    Text(
                      currentData['uploadDateDetail'],
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
