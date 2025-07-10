import 'package:flutter/material.dart';
import 'gallery_page.dart';

void main() {
  runApp(GalleryApp());
}

class GalleryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GalleryPage(),
    );
  }
}
